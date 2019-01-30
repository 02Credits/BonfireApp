import m from "mithril"
import arbiter from "promissory-arbiter"

import renderTime from "./time"

export default (doc) ->
  if !doc.author?
    doc.author = "error"
  titleClass = if doc.fb then ".card-title.fb-card-title" else ".card-title"
  editIcon = if doc.edited then m "i.material-icons.editIcon", "mode_edit" else null
  m "div", [
    m "span" + titleClass, {
        ondblclick: -> arbiter.publish "messages/startReact", doc._id
      }, [
      m.trust(doc.author)
      editIcon
    ]
    await renderTime doc
  ]
