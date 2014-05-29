path = require 'path'

{Model} = require 'theorist'
_ = require 'underscore-plus'

FTPFile = require './ftp-file'
Client = require('ftp')

module.exports =
class FTPDirectory extends Model
  @properties
    path: null
    name: null
    isRoot: false
    isExpanded: false
    client: null
    rawlist: -> {}
    entries: false
    expandedEntries: -> {}

  constructor: ->
    super

  destroyed: ->

  loadDirectory: ->
    directory = @
    @client.ls path.join(@path, @name), (err, list) ->
      throw err if err
      directory.rawlist = list
      directory.parseRawList()

  parseRawList: ->
    parsedEntries = []
    for item in @rawlist
      unless @isPathIgnored(item.path) or item.name is '.' or item.name is '..'
        if item.type is 1
          entry = new FTPDirectory({client: @client, name: item.name, isRoot: false, path: path.join(@path, @name), isExpanded: false})
        else
          entry = new FTPFile(path.join @path, @name, item.name)
        parsedEntries.push entry
    @entries = parsedEntries
    @emit 'directory-loaded', parsedEntries

  # Is the given path ignored?
  isPathIgnored: (filePath) ->
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

  # Public: Does this directory contain the given path?
  #
  # See atom.Directory::contains for more details.
  contains: (pathToCheck) ->
    @directory.contains(pathToCheck)

  # Public: Perform a synchronous reload of the directory.
  reload: ->

  # Public: Collapse this directory and stop watching it.
  collapse: ->
    @isExpanded = false
    @expandedEntries = @serializeExpansionStates()

  # Public: Expand this directory, load its children, and start watching it for
  # changes.
  expand: ->
    if @entries
      @isExpanded = true
    else
      @loadDirectory()

  serializeExpansionStates: ->
    expandedEntries = {}
    for name, entry of @entries when entry.isExpanded
      expandedEntries[name] = entry.serializeExpansionStates()
    expandedEntries
