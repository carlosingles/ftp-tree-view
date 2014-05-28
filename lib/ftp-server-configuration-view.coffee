path = require 'path'
shell = require 'shell'

_ = require 'underscore-plus'
{$, BufferedProcess, View} = require 'atom'
fs = require 'fs-plus'

module.exports =
class FTPServerConfigurationView extends View
  @content: ->
    @li class: 'server-entry list-item', =>
      @span class: 'name icon icon-server', outlet: 'listItem'

  initialize: (@server) ->
    @listItem.text(@server.name)
