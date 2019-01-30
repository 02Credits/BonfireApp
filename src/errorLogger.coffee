require "./pouchdbManager"
import PouchDB from "pouchdb"
import moment from "moment"
import arbiter from "promissory-arbiter"

errorDB = new PouchDB('http://02credits.ddns.net:5984/errors')

console.log "errorLogger initialized"

window.onerror = (err) ->
  arbiter.publish "error", err

arbiter.subscribe "error", (information) ->
  console.log information
  errorDB.put
    "_id": moment().utc().valueOf().toString()
    "user": localStorage.displayName
    "information": information
