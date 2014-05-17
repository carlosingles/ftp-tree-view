{$, View} = require 'atom'

FileView = require './file-view'
File = require './file'

module.exports =
class FTPDirectoryView extends View
  @content: ->
    @li class: 'directory entry list-nested-item collapsed', =>
      @div class: 'header list-item', outlet: 'header', =>
        @span class: 'name icon', outlet: 'directoryName'
      @ol class: 'entries list-tree', outlet: 'entries'

  initialize: (@name, @list) ->
    iconClass = 'icon-file-directory'
    @directoryName.addClass(iconClass)
    @directoryName.text(@name)
    @directoryName.attr('data-name', @name)
    @expand()

  beforeRemove: ->
    @name.destroy()
    @list.destroy()

  # subscribeToDirectory: ->
  #   @subscribe @directory, 'entry-added', (entry) =>
  #     view = @createViewForEntry(entry)
  #     insertionIndex = entry.indexInParentDirectory
  #     if insertionIndex < @entries.children().length
  #       @entries.children().eq(insertionIndex).before(view)
  #     else
  #       @entries.append(view)
  #
  #   @subscribe @directory, 'entry-added entry-removed', =>
  #     @trigger 'tree-view:directory-modified' if @isExpanded
  #
  # getPath: ->
  #   @directory.path

  # createViewForEntry: (entry) ->
  #   if entry instanceof Directory
  #     view = new DirectoryView(entry)
  #   else
  #     view = new FileView(entry)
  #
  #   subscription = @subscribe @directory, 'entry-removed', (removedEntry) ->
  #     if entry is removedEntry
  #       view.remove()
  #       subscription.off()
  #
  #   view

  # reload: ->
  #   @directory.reload() if @isExpanded

  toggleExpansion: ->
    if @isExpanded then @collapse() else @expand()

  expand: ->
    return if @isExpanded
    @addClass('expanded').removeClass('collapsed')
    # @subscribeToDirectory()
    # @directory.expand()
    @isExpanded = true
    false

  collapse: ->
    @removeClass('expanded').addClass('collapsed')
    # @directory.collapse()
    # @unsubscribe(@directory)
    @entries.empty()
    @isExpanded = false
