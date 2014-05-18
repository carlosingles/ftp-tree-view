{$, View} = require 'atom'

FTPFileView = require './ftp-file-view'
FTPFile = require './ftp-file'
FTPDirectory = require './ftp-directory'

module.exports =
class FTPDirectoryView extends View
  @content: ->
    @li class: 'directory entry list-nested-item collapsed', =>
      @div class: 'header list-item', outlet: 'header', =>
        @span class: 'name icon', outlet: 'directoryName'
      @ol class: 'entries list-tree', outlet: 'entries'

  initialize: (@directory) ->
    iconClass = 'icon-file-directory'
    if @directory.isRoot
      iconClass = 'icon-repo' if atom.project.getRepo()?.isProjectAtRoot()
    else
      iconClass = 'icon-file-submodule' if @directory.submodule
    @directoryName.addClass(iconClass)
    @directoryName.text(@directory.name)
    @directoryName.attr('data-name', @directory.name)
    @directoryName.attr('data-path', @directory.path)
    directoryView = @
    @subscribe @directory, 'directory-loaded', (entries) =>
      for entry in entries
        view = directoryView.createViewForEntry(entry)
        directoryView.entries.append(view)
    if @directory.entries
      for entry in @directory.entries
        view = @createViewForEntry(entry)
        @entries.append(view)
    @expand() if @directory.isExpanded

  beforeRemove: ->
    @directory.destroy()

  getPath: ->
    @directory.path

  createViewForEntry: (entry) ->
    if entry instanceof FTPDirectory
      view = new FTPDirectoryView(entry)
    else
      view = new FTPFileView(entry)

  reload: ->
    @directory.reload() if @isExpanded

  toggleExpansion: ->
    if @directory.isExpanded then @collapse() else @expand()

  expand: ->
    return if @isExpanded
    @addClass('expanded').removeClass('collapsed')
    @directory.expand()
    false

  collapse: ->
    @removeClass('expanded').addClass('collapsed')
    @directory.collapse()
    @isExpanded = false
