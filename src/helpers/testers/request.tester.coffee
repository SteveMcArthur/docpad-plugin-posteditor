# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('safefs')
    util = require('util')
    pathUtil = require('path')
    cleanTestPaths = require('./cleanTestPaths')
    
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
                
            # Test
            @suite 'request: load document',(suite,test) ->
                # Prepare
                
                plugin = tester.docpad.getPlugin('posteditor')
                config = plugin.getConfig()
                baseUrl = "http://localhost:"+tester.docpad.config.port
                obj = null
                test 'get document', (done) ->
                    fileUrl = "#{baseUrl}/load/1262200515233"
                    request fileUrl, (err,response,body) ->
                        obj = JSON.parse(body)
                        console.log(obj)
                        expect(err).to.not.be.ok
                        done()
                test 'document object has docId property',(done) ->
                    expect(obj.docId).to.equal(1262200515233)
                    done()
                test 'document object has title property',(done) ->
                    expect(obj.title).to.equal('Bacon Prosciutto')
                    done()
                test 'document object has content property',(done) ->
                    expect(obj.content).to.exist
                    done()
                test 'document object has slug property',(done) ->
                    expect(obj.slug).to.equal('posts-bacon-prosciutto')
                    done()

            @suite 'request: save document',(suite,test) ->
                # Prepare
                slug = 'another-new-document'
                newDoc =
                    title: "Another New Document"
                    content: "This is my content. What do you thing?"
                    user : {name: 'johnsmith', user_id: 123456}
                    slug: slug
                    
                baseUrl = "http://localhost:"+tester.docpad.config.port
                fileUrl = "#{baseUrl}/save/"
                obj = null
                test 'save document', (done) ->
                    request.post {url:fileUrl, form: newDoc}, (err,response,body) ->
                        expect(err).to.not.be.ok
                        obj = JSON.parse(body)
                        expect(obj.success).to.be.true
                        done()
                test 'document object has docId property',(done) ->
                    expect(obj.docId).to.be.a("number")
                    done()
                test 'document object has title property',(done) ->
                    expect(obj.title).to.equal("Another New Document")
                    done()
                test 'document object has content property',(done) ->
                    expect(obj.content).to.equal("This is my content. What do you thing?")
                    done()
                test 'document object has slug property',(done) ->
                    expect(obj.slug).to.equal('another-new-document')
                    done()