# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('safefs')
    util = require('util')
    path = require('path')
    beforeTest = require('./beforeTest')
    
    dataPath = null
    versionPath = null
    testSrcPosts = null
    dummyPath = null
    dummyExpectedPath = null

    # Define My Tester
    class PosteditorTester extends testers.ServerTester
        # Test Generate
        #testGenerate: testers.RendererTester::testGenerate

        testCreate: ->
            tester = @
            {dataPath,versionPath,testSrcPosts,dummyPath,dummyExpectedPath} = beforeTest(tester)

            
            super

        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super
            
            fileExists = (pathname) ->
                try
                    fs.statSync(pathname)
                    return true
                catch
                    return false
                

                
            readFile = (filename) ->
                return fs.readFileSync(filename,'utf-8')
            
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
                    content:content[2]
                }
                
                
                
            
            getDummyFiles = () ->
                items = fs.readdirSync(dummyPath)
                files = items.map (name,idx) ->
                    file = path.join(dummyPath,name)
                    stat = fs.statSync(file)
                    if stat.isFile()
                        return file
                return files
            
            files = getDummyFiles()
            console.log("SANITY CHECKER....")

            # Test
            @suite 'sanity check', (suite,test) ->
                # Prepare
                plugin = tester.docpad.getPlugin('posteditor')
                config = plugin.getConfig()
                baseUrl = "http://localhost:"+tester.docpad.config.port
                
                test 'save document', () ->
                    newDoc = getFileObject(files[0])
                    expectedDoc = getFileObject(path.join(dummyExpectedPath,'illegal-characters.html.md'))
                    fileUrl = "#{baseUrl}/save/"
                    srcFile = path.join(testSrcPosts,'illegal-characters.html.md')
                    request.post {url:fileUrl, form: newDoc}, (err,response,body) ->
                        expect(err).to.not.be.ok
                        obj = JSON.parse(body)
                        expect(obj.success).to.be.true
                        test 'check filename', () ->
                            exist = fileExists(srcFile)
                            expect(exist).to.be.true
                        test 'document content as expected', () ->
                            doc = getFileObject(srcFile)
                            expect(doc.content).to.equal(expectedDoc.content)
                            test 'document title as expected', () ->
                                expect(doc.title).to.equal(expectedDoc.title)
                        
 