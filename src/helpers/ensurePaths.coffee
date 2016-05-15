fs = require('safefs')
path = require('path')
dirExists = (pathname) ->
    try
        stats = fs.statSync(pathname)
        return stats.isDirectory()
    catch
        return false
ensurePaths = (docpad,plugin) ->
    docpadConfig = docpad.getConfig()
    config = plugin.getConfig()
    if process.env.OPENSHIFT_DATA_DIR and !config.dataPath
        config.dataPath = process.env.OPENSHIFT_DATA_DIR
    else if !config.dataPath
        config.dataPath = path.resolve(docpadConfig.rootPath,'data')
                
    if config.saveVersions
        newPath = path.join(plugin.config.dataPath,'versions')
        fs.ensurePath newPath, (err,exists) ->
            if err
                docpad.log('warn',err)

    for i, item of docpadConfig.documentsPaths
        pth = path.join(item,config.defaultSavePath)
        if dirExists(pth)
            plugin.config.defaultSavePath = pth
                    
                    
module.exports = ensurePaths