import m from "mithril"
import $ from "jquery"
import _ from "underscore"
import PouchDB from "pouchdb"
import * as collate from "pouchdb-collate"
import moment from "moment"
import arbiter from "promissory-arbiter"
import messageContainer from "./messages/container"
import inputManager from "./inputManager"
import scrollManager from "./scrollManager"
import materialize from "materialize-css"

remoteDB = new PouchDB('http://02credits.ddns.net:5984/messages')
localDB = new PouchDB('messages')

currentDB = remoteDB
caughtUp = false
editPrimed = false
searchPrimed = false

handleChange = (change) ->
  render()
  if change.doc.author != localStorage.displayName
    if notifier?
      notifier.notify true

primeQueries = () ->
  if caughtUp
    localDB.query "by_author",
      key: localStorage.displayName
      limit: 1
      descending: true
    .then () ->
      if not editPrimed
        editPrimed = true
        materialize.toast
          html: "Edit Ready"
          displayLength: 4000
    .catch (err) ->
      arbiter.publish "error", err
    localDB.search
      fields: ['text']
      build: true
    .then () ->
      if not searchPrimed
        searchPrimed = true
        materialize.toast
          html: "Search Ready"
          displayLength: 4000
    .catch (err) ->
      arbiter.publish "error", err

render = () ->
  if !inputManager.searching
    currentDB.allDocs
      include_docs: true
      conflicts: false
      attachments: true
      binary: true
      limit: scrollManager.messages
      descending: true
      startkey: "_design"
    .then (results) ->
      renderMessages(results.rows.reverse())
    .catch (err) ->
      arbiter.publish "error", err

renderMessages = (messages, preventCombining) ->
  messages = _.filter(messages, (message) ->
    doc = message.doc
    doc.author?
  )
  groupedMessages = []
  currentAuthor = {}
  currentMessage = null
  for message in messages
    if !message.doc.text? or message.doc.text.startsWith("<")
      if currentMessage?
        groupedMessages.push(currentMessage)
        currentMessage = null
      groupedMessages.push(message)
    else
      if currentMessage?
        if currentMessage.doc.author == message.doc.author and
            moment.utc(message.doc.time).diff(moment.utc(currentMessage.doc.time), 'minutes') < 2 and
            not preventCombining
          if message.doc.edited
            currentMessage.doc.edited = true
          currentMessage.doc.text.push {text: message.doc.text, id: message.doc._id}
        else
          groupedMessages.push(currentMessage)
          currentMessage = message
          message.doc.text = [{text: message.doc.text, id: message.doc._id}]
      else
        currentMessage = message
        message.doc.text = [{text: message.doc.text, id: message.doc._id}]
  if currentMessage?
    groupedMessages.push(currentMessage)

  messagePromises = []
  for message in groupedMessages
    renderedMessage = messageRenderer(message.doc)
    if renderedMessage?
      messagePromises.push(renderedMessage)
  (Promise.all messagePromises).then () ->
    m.render $('#messages').get(0),
      m "div", container.render message for message in groupedMessages
    materialize.AutoInit();
    arbiter.publish("messages/rendered")

render()
remoteChanges = remoteDB.changes
  since: 'now'
  live: true
  include_docs: true
.on 'change', handleChange
.on 'error', (err) ->
  arbiter.publish "error", err

localDB.sync(remoteDB)
.then () ->
  $('.progress').fadeOut()
  caughtUp = true
  primeQueries()
  localDB.sync remoteDB,
    live: true
    retry: true
  .on 'error', (err) ->
    arbiter.publish "error", err
  localDB.changes
    since: 'now'
    live: true
    include_docs: true
  .on 'change', handleChange
  .on 'error', (err) ->
    arbiter.publish "error", err
  remoteChanges.cancel()
  currentDB = localDB;
.catch (err) ->
  arbiter.publish "error", err

$('#input').prop('disabled', false)

arbiter.subscribe "messages/render", (messages) ->
  if !messages?
    render()
  else
    renderMessages messages

arbiter.subscribe "messages/edit", (args) ->
  id = args.id
  text = args.text
  skipMarkEdit = args.skipMarkEdit
  $('.progress').fadeIn()
  currentDB.get(id)
  .then (doc) ->
    $('.progress').fadeOut()
    doc.text = text
    if not skipMarkEdit
      doc.edited = true
    currentDB.put doc
  .catch (err) ->
    arbiter.publish "error", err
    $('.progress').fadeOut()

arbiter.subscribe "messages/react", (args) ->
  id = args.id
  emoticon = args.emoticon
  currentDB.get(id)
  .then (doc) ->
    if doc.reactions?
      for currentEmoticon, users of doc.reactions
        doc.reactions[currentEmoticon] = users.filter((name) -> name != localStorage.displayName)
      if doc.reactions[emoticon]?
        doc.reactions[emoticon].push(localStorage.displayName)
      else
        doc.reactions[emoticon] = [localStorage.displayName]
    else
      doc.reactions = { "#{emoticon}": [localStorage.displayName]}
    currentDB.put doc
  .catch (err) ->
    arbiter.publish "error", err

arbiter.subscribe "messages/search", (query) ->
  if caughtUp
    renderMessages []
    $('.progress').fadeIn()
    localDB.search
      query: query
      fields: ['text']
      include_docs: true
    .then (results) ->
      $('.progress').fadeOut()
      renderMessages(results.rows.reverse(), true)
    .catch (err) ->
      arbiter.publish "error", err
      $('.progress').fadeOut()
  else
    materialize.toast
      html: "Sync still in progress"

arbiter.subscribe "messages/send", (args) ->
  currentDB.allDocs
    include_docs: true
    conflicts: false
    limit: 1
    descending: true
    startkey: "_design"
  .then (results) ->
    lastDoc = results.rows[0].doc
    now = moment().utc()
    args.time = now.valueOf()
    args.messageNumber = parseInt(lastDoc.messageNumber) + 1
    args["_id"] = collate.toIndexableString([args.messageNumber, args.time]).replace(/\u0000/g, '\u0001');
    currentDB.put args
  .catch (err) ->
    arbiter.publish "error", err

arbiter.subscribe "messages/getLast", (callback) ->
  if caughtUp
    $('.progress').fadeIn()
    currentDB.query "by_author",
      key: localStorage.displayName;
      limit: 1
      include_docs: true
      descending: true
    .then (result) ->
      $('.progress').fadeOut()
      callback result.rows[0].doc
    .catch (err) ->
      $('.progress').fadeOut()
      arbiter.publish "error", err
  else
    materialize.toast
      html: "Sync still in progress"

arbiter.subscribe "messages/get", (args) ->
  id = args.id
  callback = args.callback
  currentDB.get(id)
  .then (doc) ->
    callback doc
  .catch (err) ->
    arbiter.publish "error", err

setInterval () ->
  primeQueries()
, 10000
