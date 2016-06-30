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
    class SanitycheckTester extends testers.ServerTester
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
                
            
            dummyObjs = dummyFiles.getDummies(tester)
            dummyExpectedPath = dummyFiles.dummyExpectedPath()

            #plugin = tester.docpad.getPlugin('posteditor')
            #config = plugin.getConfig()
            
            
            testDummyItem = (suite,test,dummy) ->
                newDoc =
                    content: dummy.content
                    title: dummy.title

                fname = path.basename(dummy.file)
                expectedDoc = dummyFiles.getFileObject(path.join(dummyExpectedPath,fname))
                test 'save document '+fname, () ->
                    srcFile = path.join(testSrcPosts,fname)
                    baseUrl = "http://localhost:"+tester.docpad.config.port
                    fileUrl = "#{baseUrl}/save/"
                    request.post {url:fileUrl, form: newDoc}, (err,response,body) ->
                        expect(err).to.not.be.ok
                        obj = JSON.parse(body)
                        expect(obj.success).to.be.true
                        
                        test 'check filename', () ->
                            exist = fileExists(srcFile)
                            expect(exist).to.be.true
                        test 'document content as expected', () ->
                            doc = dummyFiles.getFileObject(srcFile)
                            expect(doc.content).to.equal(expectedDoc.content)
                            test 'document title as expected', () ->
                                expect(doc.title).to.equal(expectedDoc.title)
                        

            # Test
            @suite 'sanity check', (suite,test) ->
                # Prepare

                for prop, val of dummyObjs
                    testDummyItem(suite,test,val)
                

                        
 