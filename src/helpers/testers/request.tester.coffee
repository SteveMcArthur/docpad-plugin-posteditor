# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('safefs')
    util = require('util')
    pathUtil = require('path')
    beforeTest = require('./beforeTest')
    
    dataPath = null
    versionPath = null
    testSrcPosts = null

    # Define My Tester
    class PosteditorTester extends testers.ServerTester
        # Test Generate
        #testGenerate: testers.RendererTester::testGenerate
        testCreate: ->
            tester = @
            {dataPath,versionPath,testSrcPosts} = beforeTest(tester)
            
            super

        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super
                
            # Test
            @suite 'server requests',(suite,test) ->
                # Prepare
                
                plugin = tester.docpad.getPlugin('posteditor')
                config = plugin.getConfig()
                baseUrl = "http://localhost:"+tester.docpad.config.port

                test 'get document', (done) ->
                    fileUrl = "#{baseUrl}/load/1262200515233"
                    request fileUrl, (err,response,body) ->
                        obj = JSON.parse(body)
                        expect(err).to.not.be.ok
                        test 'document object has docId property',() ->
                            expect(obj.docId).to.equal(1262200515233)
                        test 'document object has title property',() ->
                            expect(obj.title).to.equal('Bacon Prosciutto')
                        test 'document object has content property',() ->
                            expect(obj.content).to.exist
                        test 'document object has slug property',() ->
                            expect(obj.slug).to.equal('posts-bacon-prosciutto')
                        done()
                test 'save document', (done) ->
                    slug = 'another-new-document'
                    newDoc =
                        title: "Another New Document"
                        content: "This is my content. What do you thing?"
                        user : {name: 'johnsmith', user_id: 123456}
                        slug: slug
                    fileUrl = "#{baseUrl}/save/"
                    request.post {url:fileUrl, form: newDoc}, (err,response,body) ->
                        expect(err).to.not.be.ok
                        obj = JSON.parse(body)
                        expect(obj.success).to.be.true
                        test 'document object has docId property',() ->
                            expect(obj.docId).to.be.a("number")
                        test 'document object has title property',() ->
                            expect(obj.title).to.equal("Another New Document")
                        test 'document object has content property',() ->
                            expect(obj.content).to.equal("This is my content. What do you thing?")
                        test 'document object has slug property',() ->
                            expect(obj.slug).to.equal('another-new-document')
                        done()