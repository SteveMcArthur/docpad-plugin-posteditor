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
                return fs.readFileSync(filename)
            
            getDummyFiles = () ->
                items = fs.readdirSync(dummyPath)
                files = []
                items.forEach (file,idx) ->
                    if file.getStat().isFile()
                        files.push(file.)
                
            # Test
            @suite 'check paths', (suite,test) ->
                # Prepare
                plugin = tester.docpad.getPlugin('posteditor')
                config = plugin.getConfig()
 