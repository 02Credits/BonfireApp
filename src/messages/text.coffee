import m from "mithril"
import arbiter from "promissory-arbiter"
import linkify from "linkifyjs/string"
import emoticons from "../emoticons"

import title from "./title"
import fileAttachments from "./fileAttachments"

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

export default
  buildContext: (doc) ->
    await title.buildContext doc
    await fileAttachments.buildContext doc

  render: (context) ->
    renderedTitle = title.render context
    renderedFileAttachments = fileAttachments.render context
    if context.text?
      if Array.isArray(context.text)
        elements = [renderedTitle]
        for text in context.text
          elements.push(renderText(text.text, context.author, text.id))
        elements.push(renderedFileAttachments)
        elements
      else
        [
          renderedTitle
          renderText(context.text, context.author, context._id)
          renderedFileAttachments
        ]
    else
      [
        renderedTitle
        renderedFileAttachments
      ]
