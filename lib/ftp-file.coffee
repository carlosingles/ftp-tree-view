path = require 'path'
fs = require 'fs-plus'
{Model} = require 'theorist'

module.exports =
class FTPFile extends Model
  @properties
    file: null
    path: null
    raw: null
  @::accessor 'name', -> path.basename(@path)
  @::accessor 'directory', -> path.dirname(@path)
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

  constructor: (path, raw) ->
    super
    @raw = raw
    @path = path

  getStringDetails: ->
    return new Date(@raw.time).toLocaleString() + ' | ' + @bytesToSize(@raw.size) + ' | ' + @getOctalPermissions()

  getOctalPermissions: ->
    user  = @permissionObjectToDigit(@raw.userPermissions)
    group = @permissionObjectToDigit(@raw.groupPermissions)
    other = @permissionObjectToDigit(@raw.otherPermissions)
    return '0' + user + group + other

  permissionObjectToDigit: (p) ->
    value = 0
    value += 1 if p.exec is true
    value += 2 if p.write is true
    value += 4 if p.read is true
    return value

  bytesToSize: (bytes) ->
    return "0 bytes" if bytes is 0
    k = 1024
    sizes = [
      "bytes"
      "KB"
      "MB"
      "GB"
      "TB"
      "PB"
      "EB"
      "ZB"
      "YB"
    ]
    i = Math.floor(Math.log(bytes) / Math.log(k))
    (bytes / Math.pow(k, i)).toPrecision(3) + " " + sizes[i]
