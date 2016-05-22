fs = require('fs-extra')
util = require('util')
pathUtil = require('path')
testPaths = require('./testPaths')
createDoc = require('./createDoc')
        
    
cleanTestPaths = (tester) ->

    
    {dataPath,versionPath,testSrcPosts,testOutPosts} = testPaths(tester)
    
    fs.removeSync testSrcPosts
    fs.removeSync versionPath
    fs.removeSync dataPath
    fs.mkdirsSync testSrcPosts
    createDoc(tester)
    
    return {dataPath,versionPath,testSrcPosts,testOutPosts}

            
module.exports = cleanTestPaths