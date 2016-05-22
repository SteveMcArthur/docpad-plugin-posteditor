path = require('path')
        
getPaths = (tester) ->
    testPath = tester.config.testPath
    testSrcPosts = path.join(tester.config.testPath, 'src', 'documents','posts')
    testOutPosts = path.join(tester.config.testPath, 'out', 'posts')
    dataPath = path.join(tester.config.testPath, 'data')
    versionPath = path.join(dataPath,'versions')
    
    return {dataPath,versionPath,testSrcPosts,testOutPosts}

            
module.exports = getPaths