fs = require('fs-extra')
util = require('util')
pathUtil = require('path')
createDoc = require('./createDoc')
        
    
beforeTest = (tester) ->
    testPath = tester.config.testPath
    testSrcPosts = pathUtil.join(tester.config.testPath, 'src', 'documents','posts')
    dataPath = pathUtil.join(tester.config.testPath, 'data')
    versionPath = pathUtil.join(dataPath,'versions')
    dummyPath =  pathUtil.join(tester.config.testPath, 'dummy-posts')
    dummyExpectedPath =  pathUtil.join(tester.config.testPath, 'dummy-expected')
    
    fs.removeSync testSrcPosts
    fs.removeSync versionPath
    fs.removeSync dataPath
    fs.mkdirsSync testSrcPosts
    createDoc(tester)
    
    return {dataPath,versionPath,testSrcPosts,dummyPath,dummyExpectedPath}

            
module.exports = beforeTest