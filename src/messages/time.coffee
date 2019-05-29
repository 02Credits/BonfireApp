import m from "mithril"
import moment from "moment"

import dubs from "./dubs"

export default
  buildContext: (doc) ->
    await dubs.buildContext doc

  render: (context) ->
    if doc.time?
      time = moment.utc(doc.time).local()
      timeText = time.format("M/D/h:mm")
      m "p.time-stamp.black-text.right", [
        timeText
        dubs.render context
      ]
