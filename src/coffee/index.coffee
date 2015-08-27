fs = require 'fs'
path = require 'path'

app = angular.module 'nodeNote', ['ui.tinymce']

app.controller 'DirectoryTree', ($scope, $compile) ->
  $scope.text = ''
  $scope.notesInCurrentFolder = []
  $scope.currentOpenFileScope = null
  $scope.currentOpenFolderScope = null
  $scope.treeTemplate = $('#dir-tree-tpl').html()


  $scope.openFolder = (e) ->
    if $(e.target).hasClass('open-folder-btn')
      return

    element = $ e.currentTarget
    scope = element.scope()

    if scope.item.isOpened
      return

    scope.item.isOpened = true

    if $scope.currentOpenFolderScope
      if $scope.currentOpenFolderScope.item.path != scope.item.path
        $scope.currentOpenFolderScope.item.isOpened = false

    $scope.currentOpenFolderScope = scope

    if scope.item.children.length
      $scope.notesInCurrentFolder = $scope.getAllChildNotes scope.item.children

    return true


  $scope.openNotes = (e) ->
    scope = $(e.currentTarget).scope()

    scope.item.isOpened = true

    if $scope.currentOpenFileScope
      if $scope.currentOpenFileScope.item.path != scope.item.path
        $scope.currentOpenFileScope.item.isOpened = false
      else
        return

    $scope.currentOpenFileScope = scope
    $scope.text = fs.readFileSync scope.item.path, 'utf8'
    tinyMCE.activeEditor.setContent $scope.text


  $scope.unwrapFolder = (e) ->
    element = $ e.currentTarget
    parent = element.parents('li').first()
    scope = element.scope()

    foldersCount = scope.item.children.map (child) ->
      if child.isFolder
        return child

    if scope.item.unwrapped
      scope.item.unwrapped = false
      parent.find('ul').remove()
      return

    if foldersCount[0]
      template = $compile($scope.treeTemplate)(scope)
      parent.append template.hide().fadeIn('fast')

    scope.item.unwrapped = true


  $scope.save = (filePath) ->
    content = tinyMCE.activeEditor.getContent()
    stream = fs.createWriteStream filePath
    stream.write content


  $scope.getDirTree = (dir) ->
    stat = fs.statSync dir

    fileName = dir.split path.sep
    fileName = fileName[fileName.length - 1]

    info =
      isFolder: stat.isDirectory()
      name: fileName
      path: dir

    if info.isFolder
      list = fs.readdirSync dir
      info.children = []
      info.notesCount = 0

      list.map (file) ->
        result = $scope.getDirTree path.resolve dir, file
        info.children.push result

        if not result.isFolder
          ++info.notesCount
        else
          info.notesCount += result.notesCount

    return info


  $scope.getAllChildNotes = (resource) ->
    result = []

    for item in resource
      if item.isFolder
        result = result.concat $scope.getAllChildNotes item.children
        continue
      result.push item

    return result


  $scope.tree = $scope.getDirTree '.'
