path = require 'path'
fs = require 'fs-plus'
{Model} = require 'theorist'

module.exports =
class FTPFile extends Model
  @properties
    file: null

  @::accessor 'name', -> @path.basename()
  @::accessor 'type', ->
    extension = path.extname(@path)
    if fs.isReadmePath(@path)
      'readme'
    else if fs.isCompressedExtension(extension)
      'compressed'
    else if fs.isImageExtension(extension)
      'image'
    else if fs.isPdfExtension(extension)
      'pdf'
    else if fs.isBinaryExtension(extension)
      'binary'
    else
      'text'

  constructor: (path) ->
    super
    @path = path

  # Called by theorist.
  destroyed: ->
    @unsubscribe()
