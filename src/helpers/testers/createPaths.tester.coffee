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
            {dataPath,versionPath,testSrcPosts,testOutPaths} = cleanTestPaths(tester)

            
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
            @suite 'check paths', (suite,test) ->
                # Prepare
                plugin = tester.docpad.getPlugin('posteditor')
                config = plugin.getConfig()
                test 'data path exists', (done) ->
                    exists = fileExists(dataPath)
                    expect(exists).to.be.true
                    done()
                test 'version path exists', (done) ->
                    exists = fileExists(versionPath)
                    expect(exists).to.be.true
                    done()