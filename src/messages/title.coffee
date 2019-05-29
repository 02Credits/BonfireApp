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
    m "div", [
      m "span" + titleClass, {
          ondblclick: -> arbiter.publish "messages/startReact", context._id
        }, [
        m.trust(context.author)
        editIcon
      ]
      time.render context
    ]
