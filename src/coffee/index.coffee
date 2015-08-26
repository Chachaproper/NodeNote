fs = require 'fs'
path = require 'path'

app = angular.module 'nodeNote', ['ui.tinymce']

app.controller 'DirectoryTree', ($scope, $compile) ->
  $scope.text = ''
  $scope.currentOpenFileScope = null
  $scope.treeTemplate = $('#test').html()

  $scope.open = (e) ->
    element = $ e.target
    scope = element.scope()

    if scope.item.isFolder
      if scope.item.isOpened
        scope.item.isOpened = false
        element.siblings('ul').remove()
        return

      scope.item.isOpened = true
      template = $compile($scope.treeTemplate)(scope)
      element.parent().append template
      return

    scope.item.isOpened = true

    if $scope.currentOpenFileScope
      $scope.currentOpenFileScope.item.isOpened = false

    $scope.currentOpenFileScope = scope
    $scope.text = fs.readFileSync scope.item.path, 'utf8'
    tinyMCE.activeEditor.setContent $scope.text


  $scope.save = (filePath) ->
    content = tinyMCE.activeEditor.getContent()
    stream = fs.createWriteStream filePath
    stream.write content

  $scope.getDirTree = (dir) ->
    getInfo = (dir) ->
      stat = fs.statSync dir

      fileName = dir.split path.sep
      fileName = fileName[fileName.length - 1]

      info =
        isFolder: stat.isDirectory()
        name: fileName
        path: dir

      return info

    walk = (dir) ->
      info = getInfo dir

      if not info.isFolder
        return info

      list = fs.readdirSync dir
      info.children = []

      for item in list
        filePath = path.resolve dir, item
        itemInfo = getInfo filePath

        if itemInfo.isFolder
          itemInfo.children = []

          fs.readdirSync(filePath).map (file) ->
            itemInfo.children.push walk(path.resolve filePath, file)

        info.children.push itemInfo

      return info

    return walk dir


  $scope.getNoteCount = (parent) ->
    count = 0

    for item in parent
      if not item.isFolder
        ++count

    return count


  $scope.tree = $scope.getDirTree '.'
  $scope.tree = _.sortBy($scope.tree.children, 'isFolder').reverse()



