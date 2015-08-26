fs = require 'fs'
path = require 'path'

app = angular.module 'nodeNote', ['ui.tinymce']

app.controller 'DirectoryTree', ($scope, $compile) ->
  $scope.text = ''
  $scope.notesInCurrentFolder = []
  $scope.currentOpenFileScope = null
  $scope.treeTemplate = $('#dir-tree-tpl').html()

  $scope.open = (e) ->
    element = $ e.currentTarget
    scope = element.scope()

    if scope.item.isFolder
      if scope.item.isOpened
        scope.item.isOpened = false
        element.siblings('ul').remove()
        return

      scope.item.isOpened = true

      if scope.item.children.length
        $scope.notesInCurrentFolder = scope.item.children

        template = $compile($scope.treeTemplate)(scope)
        element.parent().append template
      return

    scope.item.isOpened = true

    if $scope.currentOpenFileScope
      if $scope.currentOpenFileScope.item.path != scope.item.path
        $scope.currentOpenFileScope.item.isOpened = false
      else
        return

    $scope.currentOpenFileScope = scope
    $scope.text = fs.readFileSync scope.item.path, 'utf8'
    tinyMCE.activeEditor.setContent $scope.text


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

    if not info.isFolder
      return info

    list = fs.readdirSync dir
    info.children = []
    info.notesCount = 0

    list.map (file) ->
      result = $scope.getDirTree(path.resolve dir, file)
      info.children.push result

      if not result.isFolder
        ++info.notesCount
      else
        info.notesCount += result.notesCount

    return info


  $scope.tree = $scope.getDirTree '.'
