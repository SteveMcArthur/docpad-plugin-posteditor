# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('safefs')
    util = require('util')
    path = require('path')
    beforeTest = require('./beforeTest')
    testDocs = require('./testDocs')

    # Define My Tester
    class PropertiesExistTester extends testers.ServerTester
        
        testCreate: ->
            tester = @
            beforeTest(tester)
            
            super
        # Test Generate
        #testGenerate: testers.RendererTester::testGenerate
        testGenerate: ->
		      # Prepare
            tester = @

            # Test

            @test "generate watch", (done) ->
                tester.docpad.action 'generate watch', (err) ->
                    return done(err)

            # Chain
            @


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
            
            #{dataPath,versionPath,testSrcPosts} =beforeTest(tester)
            getDoc = () ->
                tester.docpad.getCollection('posts').findOne({docId: 1262200515233}).toJSON()
            getDocByTitle = (title) ->
                tester.docpad.getCollection('posts').findOne({title: title}).toJSON()
                
            makeOptions = (doc) ->
                opts =
                    docId: doc.docId
                    content: doc.content
                    title: doc.title
                    tags: doc.tags
                    user: {name:'johnsmith',user_id: 123456}
                return opts
            # Test
            @suite 'regeneration', (suite,test) ->
                # Prepare

                docpad = tester.docpad
                plugin = docpad.getPlugin('posteditor')
                config = plugin.getConfig()
                
                doc = getDoc()
                
                test 'edit existing doc', () ->
                    opts = makeOptions(doc)
                    opts.content = 'xxx'+opts.content
                    content = opts.content.substr(0,10)
                    plugin.saveDocument plugin,opts, (result) ->
                        expect(result.success).to.be.true

                        test 'generate edit update', () ->
                            plugin.generateUpdate 1262200515233,doc.fullPath, () ->
                                newdoc = getDoc()
                                newcontent = newdoc.content.substr(0,10)
                                expect(newcontent).to.equal(content)
                test 'create new doc', () ->
                    content = testDocs[0].content
                    title = testDocs[0].title
                    filename = testDocs[0].title.replace(config.titleReg,'').trim().toLowerCase()
                    filename = filename.replace(/[ ]/g,'-')+".html.md"
                    fullPath = path.resolve(__dirname,'..','..','..','test','src','documents','posts',filename)
                    plugin.saveDocument plugin,testDocs[0], (result) ->
                        expect(result.success).to.be.true
                        test 'file exists before regeneration', () ->
                            isThere = fileExists(fullPath)
                            expect(isThere).to.be.true
                            
                        test 'generate new update', () ->
                            plugin.generateUpdate null,doc.fullPath, () ->
                                isThere = fileExists(fullPath)
                                expect(isThere).to.be.true
                                test 'document loaded in docpad collection', () ->
                                    newdoc = getDocByTitle(title)
                                    expect(newdoc).to.have.property('title')