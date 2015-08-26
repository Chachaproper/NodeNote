fs = require 'fs'

app = angular.module 'nodeNote', ['ui.tinymce']

app.controller 'DirectoryTree', ($scope, $compile) ->
  $scope.tree = fl.getDirTree '.'
  $scope.tree = _.sortBy($scope.tree.children, 'isFolder').reverse()
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


  $scope.getNoteCount = (parent) ->
    count = 0

    for item in parent
      if not item.isFolder
        ++count

    return count

