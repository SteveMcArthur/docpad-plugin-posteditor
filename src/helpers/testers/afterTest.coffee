fs = require('safefs')
util = require('util')
pathUtil = require('path')

removeDir = (pathName) ->
    try
        fs.rmdirSync pathName
    catch err
        return

removeFile = (filePath) ->
    try
        fs.unlinkSync filePath
    catch err
        return
        
    
afterTest = (tester) ->
    console.log("After test.....")
    testPath = tester.config.testPath
    testSrcPosts = pathUtil.join(tester.config.testPath, 'src', 'documents','posts')
    dataPath = pathUtil.join(tester.config.testPath, 'data')
    versionPath = pathUtil.join(dataPath,'versions')
    
    removeDir versionPath
    removeDir dataPath

    testDoc = pathUtil.join(testSrcPosts,'my-new-document.html.md')
    removeFile(testDoc)

    testDoc2 = pathUtil.join(testSrcPosts,'another-new-document.html.md')
    removeFile(testDoc2)
    

    ###
    testOutDoc = pathUtil.join(tester.config.testPath, 'out', 'documents','posts','my-new-document.html')
    console.log(testOutDoc)
    fs.unlinkSync testOutDoc, (err) ->
        if err
            console.log(err)
    ###

            
module.exports = afterTest