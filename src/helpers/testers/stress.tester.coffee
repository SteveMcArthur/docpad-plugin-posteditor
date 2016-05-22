# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('safefs')
    util = require('util')
    path = require('path')
    cleanTestPaths = require('./cleanTestPaths')
    dummyFiles = require('./dummyFiles')
    
    dataPath = null
    versionPath = null
    testSrcPosts = null

    # Define My Tester
    class PosteditorTester extends testers.ServerTester
        # Test Generate
        #testGenerate: testers.RendererTester::testGenerate

        testCreate: ->
            tester = @
            {dataPath,versionPath,testSrcPosts} = cleanTestPaths(tester)

            
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
                
            
            dummyObjs = dummyFiles.getDummies(tester)
            dummyExpectedPath = dummyFiles.dummyExpectedPath()
            testOutPosts = path.join(tester.config.testPath, 'out', 'posts')
            

            
            longPost = null
            dummyObjs.forEach (item) ->
                if item.slug == 'long-text'
                    longPost = item
                


            #plugin = tester.docpad.getPlugin('posteditor')
            #config = plugin.getConfig()
            currentDocId = null
            doRequest = (num) ->
                baseUrl = "http://localhost:"+tester.docpad.config.port
                fileUrl = "#{baseUrl}/save/"
                newDoc =
                    content: longPost.content
                    title: longPost.title+" "+num
                if currentDocId
                    newDoc.docId = currentDocId
                request.post {url:fileUrl, form: newDoc}, (err,response,body) ->
                    expect(err).to.not.be.ok
                    obj = JSON.parse(body)
                    expect(obj.success).to.be.true
                    expect(obj.docId).to.be.number
                    currentDocId = obj.docId
                    
            runRequests = (howMany,mills,done) ->
                i=0
                end=howMany
                fn = () ->
                    if i > end
                        clearInterval(v)
                        console.log("done...")
                        if done
                            done()
                    else
                        console.log("do request..."+i)
                        doRequest(i)
                        i++
                v = setInterval(fn,mills)
             
            titleReg = /<title>(.*)<\/title>/

            # Test
            @suite 'volume check', (suite,test) ->
                # Prepare
                                                        
                test 'save document 100 times every 1/4 second', (done) ->
                    runRequests(100,250,done)

                    test '100th saved (src) post current', (done) ->
                        file = path.join(testSrcPosts,'long-text-0.html.md')
                        fileObj = dummyFiles.getFileObject(file)
                        expect(fileObj.title).to.equal('Long Text 100')
                        #need to give the DocPad regeneration process time to catch up
                        setTimeout(done,1000)
                    test '100th saved (out) post current', (done) ->
                        file = path.join(testOutPosts,'long-text-0.html')
                        html = readFile(file)
                        m = html.match(titleReg)
                        title = m[1]
                        console.log(title)
                        expect(title).to.equal('Long Text 100 | Your Website')
                        done()