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
                 
                obj = null
                test 'load document 1262200515233', (done) ->
                    obj = plugin.loadDocument(plugin,1262200515233)
                    expect(obj.success).to.be.true
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
                    console.log(obj.slug)
                    expect(obj.slug).to.equal('posts-bacon-prosciutto')
                    done()
                    