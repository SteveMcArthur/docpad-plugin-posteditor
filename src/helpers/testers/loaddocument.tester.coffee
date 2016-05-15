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
            
            fileExists = (pathname) ->
                try
                    fs.statSync(pathname)
                    return true
                catch
                    return false
                
            # Test
            @suite 'load documents', (suite,test) ->
                # Prepare
                
                plugin = tester.docpad.getPlugin('posteditor')
                config = plugin.getConfig()
                                                            
                test 'load document 1262200515233', () ->
                    obj = plugin.loadDocument(1262200515233,plugin)
                    expect(obj.success).to.be.true
                    test 'document object has docId property',() ->
                        expect(obj.docId).to.equal(1262200515233)
                    test 'document object has title property',() ->
                        expect(obj.title).to.equal('Bacon Prosciutto')
                    test 'document object has content property',() ->
                        expect(obj.content).to.exist
                    test 'document object has slug property',(done) ->
                        console.log(obj.slug)
                        expect(obj.slug).to.equal('posts-bacon-prosciutto')
                        done()
                    