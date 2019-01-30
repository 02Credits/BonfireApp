import m from "mithril"
import arbiter from "promissory-arbiter"
import * as linkify from "linkifyjs"

import renderImages from "./images"
import renderText from "./text"
import renderReactions from "./reactions"

export default (doc) ->
  if doc.text?
    if Array.isArray(doc.text)
      doc.links = []
      for text in doc.text
        if text.text.indexOf("<") != 0
          for link in linkify.find(text.text)
            doc.links.push(link)
    else if doc.text.indexOf("<") != 0
      doc.links = linkify.find doc.text

  m ".message-container." + doc.author, { key: doc["_id"] },
    m ".message.blue-grey.lighten-5",
    {
      ondblclick: ->
        if not Array.isArray(doc.text)
          arbiter.publish "messages/startEdit", doc._id
      style: {
        position: "relative"
      }
    }, [
      await renderImages doc
      m ".message-content.black-text",
        await renderText doc
      await renderReactions doc
    ]
