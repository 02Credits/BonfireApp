import m from "mithril"
import arbiter from "promissory-arbiter"
import linkify from "linkifyjs/string"
import emoticons from "../emoticons"

import renderTitle from "./title"
import renderFileAttachments from "./fileAttachments"

renderText = (text, author, id) ->
  classText = if text.indexOf(">") == 0 then ".greentext" else ""
  if text.indexOf("<") != 0
    text = linkify "#{text}",
      format: (value, type) ->
        if (type == 'url' && value.length > 50)
          value = value.slice(0, 50) + '…';
        return value
    if emoticons.singleEmoticon(text)
      return m ".emoticon", {
        style: {width: "100%", textAlign: "center"}
        ondblclick: -> arbiter.publish "messages/startEdit", id
      }, m.trust(emoticons.replace(text, id, author, true))
    else
      text = emoticons.replace(text, id, author, false)
  m "p#{classText}", {
        ondblclick: -> arbiter.publish "messages/startEdit", id
    }, m.trust(text)

export default (doc) ->
  title = await renderTitle doc
  fileAttachments = await renderFileAttachments doc
  if doc.text?
    if Array.isArray(doc.text)
      elements = [title]
      for text in doc.text
        elements.push(renderText(text.text, doc.author, text.id))
      elements.push(fileAttachments)
      elements
    else
      [
        title
        renderText(doc.text, doc.author, doc._id)
        fileAttachments
      ]
  else
    [
      title
      fileAttachments
    ]
