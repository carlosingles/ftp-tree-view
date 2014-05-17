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
    atom.workspaceView.command 'ftp-tree-view:show', => @createView().show()
    atom.workspaceView.command 'ftp-tree-view:toggle', => @createView().toggle()
    atom.workspaceView.command 'ftp-tree-view:toggle-focus', => @createView().toggleFocus()
    atom.workspaceView.command 'ftp-tree-view:reveal-active-file', => @createView().revealActiveFile()
    atom.workspaceView.command 'ftp-tree-view:toggle-side', => @createView().toggleSide()
    atom.workspaceView.command 'ftp-tree-view:add-file', => @createView().add(true)
    atom.workspaceView.command 'ftp-tree-view:add-folder', => @createView().add(false)
    atom.workspaceView.command 'ftp-tree-view:duplicate', => @createView().copySelectedEntry()
    atom.workspaceView.command 'ftp-tree-view:remove', => @createView().removeSelectedEntries()

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
