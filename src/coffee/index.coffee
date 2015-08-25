fs = require 'fs'

app = angular.module 'nodeNote', ['ui.tinymce']

app.controller 'DirectoryTree', ($scope, $compile) ->
  $scope.tree = getDirTree '.'
  $scope.text = ''
  $scope.currentFilePath = ''


  $scope.open = (e) ->
    template = angular.element(document.querySelector('#test')).html()
    scope = angular.element(e.target).scope()

    if scope.item.isFolder
      if scope.item.isOpened
        scope.item.isOpened = false
        angular.element(e.target).next('ul').remove()
        return

      scope.item.isOpened = true
      template = $compile(template)(scope)
      angular.element(e.target).parent().append template

      return

    $scope.text = fs.readFileSync scope.item.path, 'utf8'
    $scope.currentFilePath = scope.item.path
    tinyMCE.activeEditor.setContent $scope.text


  $scope.save = (filePath) ->
    stream = fs.createWriteStream filePath
    stream.write $scope.text

