fs = require 'fs'
path = require 'path'

fl =
  getDirTree: (dir) ->
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




