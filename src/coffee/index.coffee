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

    if $(e.target).hasClass('open-folder-btn')
      return

    if scope.item.isFolder
      if scope.item.isOpened
        return

      scope.item.isOpened = true

      if scope.item.children.length
        $scope.notesInCurrentFolder = scope.item.children

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
      scope.item.unwrapped = true

      template = $compile($scope.treeTemplate)(scope)
      parent.append template
    return true


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
        result = $scope.getDirTree(path.resolve dir, file)
        info.children.push result

        if not result.isFolder
          ++info.notesCount
        else
          info.notesCount += result.notesCount

    return info


  $scope.tree = $scope.getDirTree '.'
