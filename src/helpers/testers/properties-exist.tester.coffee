# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('safefs')
    util = require('util')
    pathUtil = require('path')
    cleanTestPaths = require('./cleanTestPaths')

    # Define My Tester
    class PropertiesExistTester extends testers.ServerTester
        # Test Generate
        #testGenerate: testers.RendererTester::testGenerate
        testCreate: ->
            tester = @
            cleanTestPaths(tester)
            
            super

        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super
 
            # Test
            @suite 'plugin properites', (suite,test) ->
                # Prepare
                
                plugin = tester.docpad.getPlugin('posteditor')
                config = plugin.getConfig()
                
                
                @suite 'config properties exist', (suite,test,done) ->
                    expectedConfig = [
                        "customFields",
                        "dataPath",
                        "defaultLayout",
                        "postCollection",
                        "defaultSavePath",
                        "saveVersions",
                        "loadURL",
                        "saveURL",
                        "sendRenderedContent",
                        "handleRegeneration",
                        "generateHomePage",
                        "sanitize",
                        "titleReg"
                    ]

                    expectedConfig.forEach (item) ->
                        test item+' property', () ->
                            expect(config).to.have.property(item)
                    
                    done()
                                            
                @suite 'plugin methods are functions', (suite,test,done) ->
                    expectedMethods = [
                        "ensurePaths",
                        "saveDocument",
                        "loadDocument",
                        "getUserDetails",
                        "triggerGenerate",
                        "generateUpdate"
                    ]

                    expectedMethods.forEach (item) ->
                        test item+' method', () ->
                            console.log(item)
                            expect(plugin[item]).to.be.instanceof(Function)
                    
                    done()
                
               
                                