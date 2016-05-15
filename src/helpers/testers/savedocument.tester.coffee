# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('safefs')
    path = require('path')
    util = require('util')
    pathUtil = require('path')
    beforeTest = require('./beforeTest')
    testDocs = require('./testDocs')
    saveDocuments = require('../saveDocuments').methods
    
    
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
            
            doc1 = testDocs[0]
            doc2 = testDocs[1]
            # Test
            @suite 'individual saveDocuments methods', (suite,test) ->
                docpad = tester.docpad
                plugin = docpad.getPlugin('posteditor')
                config = plugin.getConfig()
                posts = docpad.getCollection('posts').toJSON()
                document = posts[0]
                input =
                    docId: document.meta.docId
                    title: 'A New Title'
                    newProp: 'some-property'
                #clone the input object as the mergeMetaData method
                #actually changes the passed input prameter
                inputClone = JSON.parse(JSON.stringify(input))
                test 'mergeMetadData method', () ->
                    {fullPath,opts} = saveDocuments.mergeMetaData(plugin, inputClone)
                    test 'returns fullPath', () ->
                        expect(fullPath).to.equal(document.fullPath)
                    test 'returns meta object', () ->
                        expect(opts).to.be.object
                    test 'returns meta.title', () ->
                        expect(opts.title).to.equal(input.title)
                    test 'returns meta.newProp', () ->
                        expect(opts.newProp).to.equal(input.newProp)
                    test 'returns meta.docId', () ->
                        expect(opts.docId).to.equal(input.docId)
                    test 'returns meta.slug', () ->
                        expect(opts.slug).to.equal(document.slug)
                    test 'returns meta.layout', () ->
                        expect(opts.layout).to.equal(document.layout)
                        
                test 'buildContent method', () ->
                    opts = JSON.parse(JSON.stringify(doc2))
                    opts.docId = 1463223638676
                    optsClone = JSON.parse(JSON.stringify(opts))
                        
                    {fileContent,docMeta} = saveDocuments.buildContent(optsClone,plugin)
                    
                    test 'returns docMeta', () ->
                        expect(docMeta).to.be.object
                    test 'returns docMeta.title', () ->
                        expect(docMeta.title).to.equal(opts.title)
                    test 'returns docMeta.docId', () ->
                        expect(docMeta.docId).to.equal(opts.docId)
                    test 'returns fileContent', () ->
                        expect(fileContent).to.be.string
                    test 'fileContent has expected content: docId', () ->
                        m = fileContent.search(/^---\ndocId: 1463223638676/)
                        expect(m).to.not.equal(-1)
                    test 'fileContent has expected content: title', () ->
                        m = fileContent.search(/title: Another New Document/)
                        expect(m).to.not.equal(-1)
                    test 'fileContent has expected content: layout', () ->
                        m = fileContent.search(/layout: post/)
                        expect(m).to.not.equal(-1)
                    test 'fileContent has expected content: edit_user', () ->
                        m = fileContent.search(/edit_user: annsmith/)
                        expect(m).to.not.equal(-1)
                    test 'fileContent has expected content: edit_user_id', () ->
                        m = fileContent.search(/edit_user_id: 789123/)
                        expect(m).to.not.equal(-1)
                    test 'fileContent has expected content: img', () ->
                        m = fileContent.search(/img:/)
                        expect(m).to.equal(-1)
                    test 'fileContent has expected content: slug', () ->
                        m = fileContent.search(/slug: another-new-document\n---/)
                        expect(m).to.not.equal(-1)
                    test 'fileContent has expected content: content', () ->
                        m = fileContent.search(/---\nThis is my content. What do you thing?/)
                        expect(m).to.not.equal(-1)
            
            @suite 'save new document', (suite,test) ->
                # Prepare
                
                plugin = tester.docpad.getPlugin('posteditor')
                config = plugin.getConfig()
               
                test 'save document doc1', () ->
                    filename = doc1.title.replace(config.titleReg,'').trim().toLowerCase()
                    filename = filename.replace(/[ ]/g,'-')+".html.md"
                    fullPath = path.resolve(__dirname,'..','..','..','test','src','documents','posts',filename)
                    plugin.saveDocument plugin,doc1,(result) ->
                        console.log("doc1 saved..")
                        expect(result.success).to.be.true
                        test 'doc1 has title', () ->
                            expect(result.title).to.equal(doc1.title)
                        test 'doc1 has content', () ->
                            expect(result.content).to.equal(doc1.content)
                        test 'doc1 has slug', () ->
                            expect(result.slug).to.equal(doc1.slug)
                        test 'doc1 has docId', () ->
                            expect(result.title).to.be.number
                        test 'document exists on file system', () ->
                            isThere = fileExists(fullPath)
                            expect(isThere).to.be.true

            @suite 'save existing document', (suite,test) ->
                # Prepare
                
                docpad = tester.docpad
                plugin = docpad.getPlugin('posteditor')
                config = plugin.getConfig()
                posts = docpad.getCollection('posts').toJSON()
                document = posts[0]
                fullPath = document.fullPath
                opts =
                    docId: document.docId
                    content: "xxx"+document.content
                    title: "xxx"+document.title
                    tags: document.tags
                    img: document.img
                    slug: document.slug
                    user:  {name: 'annsmith', user_id: 789123}
                
                
                test 'save document', () ->
                    plugin.saveDocument plugin,opts,(result) ->
                        console.log("document saved..")
                        expect(result.success).to.be.true
                        test 'document has title', () ->
                            expect(result.title).to.equal(opts.title)
                        test 'document has content', () ->
                            expect(result.content).to.equal(opts.content)
                        test 'document has slug', () ->
                            expect(result.slug).to.equal(opts.slug)
                        test 'document has docId', () ->
                            expect(result.docId).to.be.equal(opts.docId)
                        test 'document exists on file system', () ->
                            isThere = fileExists(fullPath)
                            expect(isThere).to.be.true