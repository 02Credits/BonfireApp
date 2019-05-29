import m from "mithril"
import arbiter from "promissory-arbiter"

import time from "./time"

export default
  buildContext: (doc) ->
    await time.buildContext doc

  render: (context) ->
    if !context.author?
      context.author = "error"
    titleClass = if context.fb then ".card-title.fb-card-title" else ".card-title"
    editIcon = if context.edited then m "i.material-icons.editIcon", "mode_edit" else null
    m "div.flex", [
      m "span.flex-grow-1" + titleClass, {
          ondblclick: -> arbiter.publish "messages/startReact", context._id
        }, [
        m.trust(context.author)
        editIcon
      ]
      m "div", [
        time.render context
      ]
    ]
