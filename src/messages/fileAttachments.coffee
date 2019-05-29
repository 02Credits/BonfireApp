import m from "mithril"
import arbiter from "promissory-arbiter"
import PouchDB from "pouchdb"

db = new PouchDB('http://02credits.ddns.net:5984/attachments')

export default
  buildContext: (doc) ->
    thenables = []
    if doc.file? or doc.files?
      if (doc.file)
        doc.files = [doc.file]
      doc.files = []
      thenables = for file in doc.files
        new Promise (resolve, reject) ->
          arbiter.publish "files/fetch", file
          id = arbiter.subscribe "file/data", (fileData) ->
            if fileData.id == file
              doc.files.push fileData
              arbiter.unsubscribe id
              resolve()
    await Promise.all(thenables)
  render: (context) ->
    if context.fileAttachments?
      for fileAttachment in context.fileAttachments
        m "p",
          (m "a", {
            href: URL.createObjectURL(fileAttachment.attachment.data),
            download: fileAttachment.name
          }, [ fileAttachment.name ])
