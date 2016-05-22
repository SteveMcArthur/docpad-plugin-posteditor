path = require('path')
fs = require('fs')
                
readFile = (filename) ->
    return fs.readFileSync(filename,'utf-8')

slugify = (input) ->
    input = input.trim().toLowerCase()
    input = input.replace(/[^a-zA-Z0-9]/g,'-').replace(/^-/,'').replace(/-+/g,'-').trim()
    input = input.replace(/-$/,'').trim()
    return input

titleReg = new RegExp(/title\s?:\s?(.*)/)
layoutReg = new RegExp(/layout\s?:\s?(.*)/)
getFileObject = (filename) ->
    txt = readFile(filename)
    title = txt.match(titleReg)
    layout = txt.match(layoutReg)
    content = txt.split('---')
    return {
        title: title[1],
        layout: layout[1],
        content:content[2],
        slug: slugify(title[1]),
        file: filename
    }


getDummyFiles = (dummyPath) ->
    items = fs.readdirSync(dummyPath)
    files = items.map (name,idx) ->
        file = path.join(dummyPath,name)
        stat = fs.statSync(file)
        if stat.isFile()
            return file
    return files

dummyExpectedPath = ""

getDummies = (tester) ->
    dummyPath =  path.join(tester.config.testPath, 'dummy-posts')
    dummyExpectedPath =  path.join(tester.config.testPath, 'dummy-expected')
    dummyFiles = getDummyFiles(dummyPath)
    dummies = []
    dummyFiles.forEach (file) ->
        obj = getFileObject(file)
        dummies.push(obj)
    return dummies
        
module.exports.getDummies = getDummies
module.exports.getFileObject = getFileObject
module.exports.dummyExpectedPath = () -> dummyExpectedPath
    