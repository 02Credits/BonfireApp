import m from "mithril"
import arbiter from "promissory-arbiter"
import linkify from "linkifyjs/string"
import emoticons from "../emoticons"

export default (doc) ->
  reactions = []
  if doc.reactions?
    for emoticon, users of doc.reactions
      if users.length != 0
        reactions.push(m.trust(emoticons.genEmoticon emoticon))

        if users.length > 1
            reactions.push(m "span", {
              style: {
                padding: "2px"
                borderRadius: "5px"
                marginLeft: "-8px"
                backgroundColor: "rgb(236, 239, 241)"
                boxShadow: "0 2px 2px 0 rgba(0,0,0,0.14), 0 1px 5px 0 rgba(0,0,0,0.12), 0 3px 1px -2px rgba(0,0,0,0.2)"
              }
            }, users.length.toString())

  m ".message-responses", { style:
    {
      position: "absolute",
      right: "0px",
      top: "0px",
      paddingLeft: "10px",
      paddingTop: "5px"
      transform: "translate(100%, 0)"
    }
  }, reactions
