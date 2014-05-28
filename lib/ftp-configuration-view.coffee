path = require 'path'
shell = require 'shell'

_ = require 'underscore-plus'
{$, BufferedProcess, ScrollView, EditorView} = require 'atom'
fs = require 'fs-plus'

FTPServerConfigurationView = require './ftp-server-configuration-view'

module.exports =
class FTPConfigurationView extends ScrollView
  @content: ->
    @div class: 'ftp-configuration-view-scroller', outlet: 'scroller', =>
      @ol class: 'ftp-configuration-list full-menu list-group focusable-panel', outlet: 'connectionList'

  initialize: (state) ->
    super
    ## load server list json file
    # get config path
    ftpConfigPath = atom.getConfigDirPath() + '/packages/ftp-tree-view/ftp-tree-view-config.json'
    that = @

    # open file in append mode (creating file if doesnt exist)
    fs.open ftpConfigPath, 'a+', (err, fd) ->
      throw err if err
      # read file and parse into config object
      fs.readFile ftpConfigPath, 'utf8', (err, data) ->
        throw err if err
        if data
          currentConfig = JSON.parse(data)
        currentConfig = {servers: []} unless currentConfig
        for server in currentConfig.servers
          that.connectionList.append(new FTPServerConfigurationView(server))
