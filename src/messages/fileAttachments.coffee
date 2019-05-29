import m from "mithril"
import arbiter from "promissory-arbiter"
import PouchDB from "pouchdb"

db = new PouchDB('http://02credits.ddns.net:5984/attachments')

export default (doc) ->
  if doc.file? or doc.files?
    if (doc.file)
      doc.files = [doc.file]
    renderedFiles = []
    thenables = for file in doc.files
      new Promise (resolve, reject) ->
        arbiter.publish "files/fetch", file
        id = arbiter.subscribe "file/data", (fileData) ->
          if fileData.id == file
            renderedFiles.push (m "p", (m "a", {href: URL.createObjectURL(fileData.attachment.data), download: fileData.name}, [
                fileData.name
              ]))
            arbiter.unsubscribe id
            resolve()
    Promise.all(thenables).then () -> renderedFiles
