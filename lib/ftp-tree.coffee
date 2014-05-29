path = require 'path'

module.exports =
  configDefaults:
    hideVcsIgnoredFiles: false
    hideIgnoredNames: false
    showOnRightSide: true
  treeView: null

  activate: (@state) ->
    @state.attached = true
    @createView() if @state.attached

  deactivate: ->
    @treeView?.deactivate()
    @treeView = null

  serialize: ->
    if @treeView?
      @treeView.serialize()
    else
      @state

  createView: ->
    unless @treeView?
      FTPTreeView = require './ftp-tree-view'
      @treeView = new FTPTreeView(@state)
    @treeView

  shouldAttach: ->
    if atom.workspace.getActivePaneItem()
      false
    else if path.basename(atom.project.getPath()) is '.git'
      # Only attach when the project path matches the path to open signifying
      # the .git folder was opened explicitly and not by using Atom as the Git
      # editor.
      atom.project.getPath() is atom.getLoadSettings().pathToOpen
    else
      true
