import PouchDB from "pouchdb"
PouchDB.plugin(require("pouchdb-quick-search"))
PouchDB.plugin(require("pouchdb-upsert"))
