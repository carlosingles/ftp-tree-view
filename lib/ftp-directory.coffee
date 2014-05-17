path = require 'path'

{Model} = require 'theorist'
_ = require 'underscore-plus'

FTPFile = require './ftp-file'

module.exports =
class FTPDirectory extends Model
  @properties
    directory: null
    isRoot: false
    isExpanded: false
    entries: -> {}
    expandedEntries: -> {}

  @::accessor 'name', -> @directory.getBaseName()
  @::accessor 'path', -> @directory.getPath()

  constructor: ->
    super

  destroyed: ->
    @unwatch()
    @unsubscribe()


  # Is the given path ignored?
  isPathIgnored: (filePath) ->
    if atom.config.get('tree-view.hideVcsIgnoredFiles')
      repo = atom.project.getRepo()
      return true if repo? and repo.isProjectAtRoot() and repo.isPathIgnored(filePath)

    if atom.config.get('tree-view.hideIgnoredNames')
      ignoredNames = atom.config.get('core.ignoredNames') ? []
      ignoredNames = [ignoredNames] if typeof ignoredNames is 'string'
      name = path.basename(filePath)
      return true if _.contains(ignoredNames, name)
      extension = path.extname(filePath)
      return true if extension and _.contains(ignoredNames, "*#{extension}")

    false

  # Create a new model for the given atom.File or atom.Directory entry.
  createEntry: (entry, index) ->
    if entry.getEntriesSync?
      expandedEntries = @expandedEntries[entry.getBaseName()]
      isExpanded = expandedEntries?
      entry = new Directory({directory: entry, isExpanded, expandedEntries})
    else
      entry = new File(file: entry)
    entry.indexInParentDirectory = index
    entry

  # Public: Does this directory contain the given path?
  #
  # See atom.Directory::contains for more details.
  contains: (pathToCheck) ->
    @directory.contains(pathToCheck)

  # Public: Stop watching this directory for changes.
  unwatch: ->
    if @watchSubscription?
      @watchSubscription.off()
      @watchSubscription = null
      if @isAlive()
        for key, entry of @entries
          entry.destroy()
          delete @entries[key]

  # Public: Watch this directory for changes.
  #
  # The changes will be emitted as 'entry-added' and 'entry-removed' events.
  watch: ->
    unless @watchSubscription?
      @watchSubscription = @directory.on 'contents-changed', => @reload()
      @subscribe(@watchSubscription)

  # Public: Perform a synchronous reload of the directory.
  reload: ->
    newEntries = []
    removedEntries = _.clone(@entries)
    index = 0

    for entry in @directory.getEntriesSync()
      name = entry.getBaseName()
      if @entries.hasOwnProperty(name)
        delete removedEntries[name]
        index++
      else if not @isPathIgnored(entry.path)
        newEntries.push([entry, index])
        index++

    for name, entry of removedEntries
      entry.destroy()
      delete @entries[name]
      delete @expandedEntries[name]
      @emit 'entry-removed', entry

    for [entry, index] in newEntries
      entry = @createEntry(entry, index)
      @entries[entry.name] = entry
      @emit 'entry-added', entry

  # Public: Collapse this directory and stop watching it.
  collapse: ->
    @isExpanded = false
    @expandedEntries = @serializeExpansionStates()
    @unwatch()

  # Public: Expand this directory, load its children, and start watching it for
  # changes.
  expand: ->
    @isExpanded = true
    @reload()
    @watch()

  serializeExpansionStates: ->
    expandedEntries = {}
    for name, entry of @entries when entry.isExpanded
      expandedEntries[name] = entry.serializeExpansionStates()
    expandedEntries
