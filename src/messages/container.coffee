import m from "mithril"
import arbiter from "promissory-arbiter"
import * as linkify from "linkifyjs"

import images from "./images"
import text from "./text"
import reactions from "./reactions"

export default
  buildContext: (doc) ->
    if doc.text?
      if Array.isArray(doc.text)
        doc.links = []
        for text in doc.text
          if text.text.indexOf("<") != 0
            for link in linkify.find(text.text)
              doc.links.push(link)
      else if doc.text.indexOf("<") != 0
        doc.links = linkify.find doc.text
    await images.buildContext doc
    await text.buildContext doc
    await reactions.buildContext doc

  render: (context) ->
    m ".message-container." + context.author, { key: context["_id"] },
      m ".message.blue-grey.lighten-5",
      {
        ondblclick: ->
          if not Array.isArray(context.text)
            arbiter.publish "messages/startEdit", context._id
        style: {
          position: "relative"
        }
      }, [
        images.render context
        m ".message-content.black-text",
          text.render context
        reactions.render context
      ]
