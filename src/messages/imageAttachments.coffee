import m from "mithril"
import arbiter from "promissory-arbiter"
import PouchDB from "pouchdb"

db = new PouchDB('http://02credits.ddns.net:5984/attachments')

export default
  buildContext: (doc) ->
    if doc.file? or doc.files?
      if (doc.file)
        doc.files = [doc.file]
      doc.imageAttachments = []
      thenables = for file in doc.files
        new Promise (resolve, reject) ->
          arbiter.publish "files/fetch", file
          id = arbiter.subscribe "file/data", (fileData) ->
            if fileData.id == file
              if fileData.attachment.content_type.startsWith("image")
                doc.imageAttachments.push fileData.attachment.data
              arbiter.unsubscribe id
              resolve()
    await Promise.all(thenables)
  render: (context) ->
    for imageAttachment in imageAttachments
      m "img.materialboxed", {src: URL.createObjectURL(imageAttachment)}
