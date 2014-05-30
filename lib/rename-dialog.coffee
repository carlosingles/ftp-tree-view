path = require 'path'
fs = require 'fs-plus'
Dialog = require './dialog'

module.exports =
class RenameDialog extends Dialog
  remotePath: null
  isDirectory: false
  constructor: (entryPath, isDirectory) ->
    initialName = path.basename(entryPath)
    @isDirectory = isDirectory
    @remotePath = path.normalize(entryPath)
    super
      prompt: "Rename " + ((if @isDirectory then "folder" else "file")) + " : " + @remotePath
      initialPath: initialName
      select: false
      iconClass: 'icon-terminal'

  onConfirm: (relativePath) ->
    endsWithDirectorySeparator = /\/$/.test(relativePath)
    pathToCreate = relativePath
    return unless pathToCreate
    if endsWithDirectorySeparator and !@isDirectory
      @showError("File names must not end with a '/' character.")
    else
      originalPath = path.normalize(@remotePath)
      newPath = path.normalize(path.dirname(@remotePath) + '/' + pathToCreate)
      @trigger 'rename-entry', [originalPath, newPath]
      @close()

    # try
    #   if fs.existsSync(pathToCreate)
    #     @showError("'#{pathToCreate}' already exists.")
    #   else if @isCreatingFile
    #     if endsWithDirectorySeparator
    #       @showError("File names must not end with a '/' character.")
    #     else
    #       fs.writeFileSync(pathToCreate, '')
    #       atom.project.getRepo()?.getPathStatus(pathToCreate)
    #       @trigger 'file-created', [pathToCreate]
    #       @close()
    #   else
    #     fs.makeTreeSync(pathToCreate)
    #     @trigger 'directory-created', [pathToCreate]
    #     @cancel()
    # catch error
    #   @showError("#{error.message}.")
