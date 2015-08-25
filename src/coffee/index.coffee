fs = require 'fs'

app = angular.module 'nodeNote', ['ui.tinymce']

app.controller 'DirectoryTree', ($scope, $compile) ->
  $scope.tree = getDirTree '.'
  $scope.text = ''
  $scope.currentOpenFileScope = null


  $scope.open = (e) ->
    template = angular.element(document.querySelector('#test')).html()
    element = $ e.target
    scope = element.scope()

    if scope.item.isFolder
      if scope.item.isOpened
        scope.item.isOpened = false
        element.siblings('ul').remove()
        return

      scope.item.isOpened = true
      template = $compile(template)(scope)
      element.parent().append template

      return

    scope.item.isOpened = true

    if $scope.currentOpenFileScope
      $scope.currentOpenFileScope.item.isOpened = false

    $scope.currentOpenFileScope = scope
    $scope.text = fs.readFileSync scope.item.path, 'utf8'
    tinyMCE.activeEditor.setContent $scope.text


  $scope.save = (filePath) ->
    stream = fs.createWriteStream filePath
    stream.write $scope.text

