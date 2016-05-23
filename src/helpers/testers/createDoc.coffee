fs = require('fs-extra')
util = require('util')
path = require('path')

getFiles = (testPath) ->
    items = fs.readdirSync(testPath)
    files = items.map (name,idx) ->
        file = path.join(testPath,name)
        stat = fs.statSync(file)
        if stat.isFile()
            return file
    return files

createDoc = (tester) ->
    srcPath = path.join(tester.config.testPath, 'src', 'documents','posts')
    testPostsPath = path.join(tester.config.testPath, 'test-posts')
    
    files = getFiles(testPostsPath)
    files.forEach (file) ->
        name = path.basename(file)
        if name == "bacon-prosciutto.html.md"
            outfile = path.join(srcPath,name)
            fs.copySync(file,outfile)
    
module.exports = createDoc