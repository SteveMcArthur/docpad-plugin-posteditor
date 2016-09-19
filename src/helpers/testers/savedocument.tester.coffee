# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('safefs')
    path = require('path')
    util = require('util')
    pathUtil = require('path')
    cleanTestPaths = require('./cleanTestPaths')
    testDocs = require('./testDocs')
    saveDocuments = require('../saveDocuments').methods
    
    
    dataPath = null
    versionPath = null
    testSrcPosts = null
    testOutPosts = null

    # Define My Tester
    class PosteditorTester extends testers.ServerTester
        # Test Generate
        #testGenerate: testers.RendererTester::testGenerate

        testCreate: ->
            tester = @
            {dataPath,versionPath,testSrcPosts,testOutPosts} = cleanTestPaths(tester)
            
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
            @suite 'mergeMetaData method', (suite,test) ->

                docpad = tester.docpad
                plugin = docpad.getPlugin('posteditor')
                posts = docpad.getCollection('posts').toJSON()
                document = posts[0]
                
                input =
                    docId: document.meta.docId
                    title: 'A New Title'
                    newProp: 'some-property'
                #clone the input object as the mergeMetaData method
                #actually changes the passed input prameter
                inputClone = JSON.parse(JSON.stringify(input))
                                
                fullPath = null
                opts = null
                test 'call mergeMetadData', (done) ->
                    {fullPath,opts} = saveDocuments.mergeMetaData(plugin, inputClone)
                    expect(fullPath).to.equal(document.fullPath)
                    expect(opts).to.not.equal(null)
                    done()
                test 'returns meta.title', (done) ->
                    expect(opts.title).to.equal(input.title)
                    done()
                test 'returns meta.newProp', (done) ->
                    expect(opts.newProp).to.equal(input.newProp)
                    done()
                test 'returns meta.docId', (done) ->
                    expect(opts.docId).to.equal(input.docId)
                    done()
                test 'returns meta.slug', (done) ->
                    expect(opts.slug).to.equal(document.slug)
                    done()
                test 'returns meta.layout', (done) ->
                    expect(opts.layout).to.equal(document.layout)
                    done()
                    
            @suite 'buildContent method', (suite,test) ->
                
                docpad = tester.docpad
                plugin = docpad.getPlugin('posteditor')
                fileContent = null
                docMeta = null
                opts = null
                test 'call buildContent', (done) ->
                    opts = JSON.parse(JSON.stringify(doc2))
                    opts.docId = 1463223638676
                    optsClone = JSON.parse(JSON.stringify(opts))
                        
                    {fileContent,docMeta} = saveDocuments.buildContent(optsClone,plugin)
                    expect(docMeta).to.not.equal(null)
                    expect(fileContent).to.be.string
                    done()
                    
                test 'returns docMeta.title', (done) ->
                    expect(docMeta.title).to.equal(opts.title)
                    done()
                test 'returns docMeta.docId', (done) ->
                    expect(docMeta.docId).to.equal(opts.docId)
                    done()
                test 'returns docMeta.author', (done) ->
                    expect(docMeta.author).to.equal(opts.author)
                    done()
                test 'fileContent has expected content: docId', (done) ->
                    m = fileContent.search(/docId: 1463223638676/)
                    expect(m).to.not.equal(-1)
                    done()
                test 'fileContent has expected content: title', (done) ->
                    m = fileContent.search(/title: Another New Document/)
                    expect(m).to.not.equal(-1)
                    done()
                test 'fileContent has expected content: author', (done) ->
                    m = fileContent.search(/author: Ann Smith/)
                    expect(m).to.not.equal(-1)
                    done()
                test 'fileContent has expected content: layout', (done) ->
                    m = fileContent.search(/layout: post/)
                    expect(m).to.not.equal(-1)
                    done()
                test 'fileContent has expected content: edit_user', (done) ->
                    m = fileContent.search(/edit_user: annsmith/)
                    expect(m).to.not.equal(-1)
                    done()
                test 'fileContent has expected content: edit_user_id', (done) ->
                    m = fileContent.search(/edit_user_id: 789123/)
                    expect(m).to.not.equal(-1)
                    done()
                test 'fileContent has expected content: img', (done) ->
                    m = fileContent.search(/img:/)
                    expect(m).to.equal(-1)
                    done()
                test 'fileContent has expected content: slug', (done) ->
                    m = fileContent.search(/slug: another-new-document/)
                    expect(m).to.not.equal(-1)
                    done()
                test 'fileContent has expected content: content', (done) ->
                    m = fileContent.search(/---\nThis is my content. What do you thing?/)
                    expect(m).to.not.equal(-1)
                    done()
            
            @suite 'save new document', (suite,test) ->
                # Prepare
                docpad = tester.docpad
                plugin = docpad.getPlugin('posteditor')
                config = plugin.getConfig()

                result = null
                fullPath = null
                test 'save document doc1', (done) ->
                    filename = doc1.title.replace(config.titleReg,'').trim().toLowerCase()
                    filename = filename.replace(/[ ]/g,'-')+".html.md"
                    fullPath = path.join(testSrcPosts,filename)
                    plugin.saveDocument plugin,doc1,(data) ->
                        console.log("doc1 saved..")
                        result = data
                        expect(result.success).to.be.true
                        done()
                test 'doc1 has title', (done) ->
                    expect(result.title).to.equal(doc1.title)
                    done()
                test 'doc1 has content', (done) ->
                    expect(result.content).to.equal(doc1.content)
                    done()
                test 'doc1 has author', (done) ->
                    expect(result.author).to.equal(doc1.author)
                    done()
                test 'doc1 has slug', (done) ->
                    expect(result.slug).to.equal(doc1.slug)
                    done()
                test 'doc1 has docId', (done) ->
                    expect(result.title).to.be.number
                    done()
                test 'document exists on file system', (done) ->
                    isThere = fileExists(fullPath)
                    expect(isThere).to.be.true
                    done()

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
                    author: document.author
                    tags: document.tags
                    img: document.img
                    slug: document.slug
                    user:  {name: 'annsmith', user_id: 789123}
                
                result = null
                test 'save document', (done) ->
                    plugin.saveDocument plugin,opts,(data) ->
                        console.log("document saved..")
                        result = data
                        expect(result.success).to.be.true
                        done()
                test 'document has title', (done) ->
                    expect(result.title).to.equal(opts.title)
                    done()
                test 'document has content', (done) ->
                    expect(result.content).to.equal(opts.content)
                    done()
                test 'document has author', (done) ->
                    expect(result.author).to.equal(opts.author)
                    done()
                test 'document has slug', (done) ->
                    expect(result.slug).to.equal(opts.slug)
                    done()
                test 'document has docId', (done) ->
                    expect(result.docId).to.be.equal(opts.docId)
                    done()
                test 'document exists on file system', (done) ->
                    isThere = fileExists(fullPath)
                    expect(isThere).to.be.true
                    done()