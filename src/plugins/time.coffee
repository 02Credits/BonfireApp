import m from "mithril"
import moment from "moment"

import renderDubs from "./dubs"

export default (doc) ->
  if doc.time?
    time = moment.utc(doc.time).local()
    timeText = time.format("M/D/h:mm")
    m "p.time-stamp.black-text.right", [
      timeText
      await renderDubs doc
    ]
