import $ from "jquery"
import materialize from "materialize-css"
import cards from "./cards"

$(document).ready ->
  materialize.AutoInit();

  $('#settings').click (e) ->
    $('label').addClass "active"

  cards()

