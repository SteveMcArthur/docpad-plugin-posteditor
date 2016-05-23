# Export Plugin
module.exports = (BasePlugin) ->
    # Define Plugin
    fs = require('safefs')
    path = require('path')
    URLS = require('url')
    util = require('util')

    class PostEditorPlugin extends BasePlugin
        # Plugin name
        name: 'posteditor'

        # Config
        config:
            #custom metadata fields outside of the standard title,layout and tags.
            #Prevents the arbitrary addition of extra (unexpected) metadata fields.
            #A validation of user input.
            customFields: []
            #Location for version files. This also needs to be outside of the
            #docpad src folder so that version files are not generated or copied to the
            #out folder. By default this will be a directory call "data" in
            #the docpad root
            dataPath: null
            
            defaultLayout: 'post'
            postCollection: 'posts'
            defaultSavePath: 'posts'

            #retain previous version of post that is edited and move it
            #to a 'version' folder
            saveVersions: true
            loadURL: '/load/:docId'
            saveURL: '/save'
            #URL to manually trigger regeneration of post
            generateURL: '/generate'
            #whether to send rendered HTML to the client or raw markdown
            #wysiwyg editors will want the rendered HTML and then this edited content
            #will have to be converted back to markdown for saving back to the server
            sendRenderedContent: true
            #manually trigger post regeneration rather than let docpad do it automatically.
            #usefull when there is a custom regeneration path - ie when documents are stored
            #outside of the docpad application root/repo. In such a case docpad will regenerate
            #ALL documents regardless if standalone=true or referencesOthers=false.
            handleRegeneration: true
            #if handleRegeneration=true then force the home page to be generated after each post update
            generateHomePage: true
            
            sanitize: require('bleach').sanitize
            
            #remember to include the space character but not the tab (\t) or newline (\n)
            titleReg: /[^A-Za-z0-9_.\-~\?!:"'$@# ]/g
            
            allowArbitraryMetadata: false
            allowableMetadata: ['title','layout','tags','img','docId','slug','editdate','edit_user','edit_user_id','author']
            
        validPaths: []
        
        ensurePaths: require('./helpers/ensurePaths')
        saveDocument: require('./helpers/saveDocuments').saveDocument
        loadDocument: require('./helpers/loadDocuments')
        
        setConfig: ->
            super
            
            plugin = @
            #setup data, versions and documents path
            @ensurePaths(@docpad,plugin)
            
        findDocument: (docId,slug) ->
            id = parseInt(docId)
            qry = {docId: id}
            #possibility of loading a document
            #that hasn't yet been assigned a docId
            if !docId && slug
                qry = {slug: slug}
            
            document = null
            model = @docpad.getCollection(@config.postCollection).findOne(qry)
            if model
                document = model.toJSON()
                
            return document
                    
        getUserDetails: (req) ->
            
            name = ""
            user_id = -1
            if req and req.user
                name = req.user.name || req.user.username || req.user.screen_name || ""
                user_id = req.user.our_id || req.user.userid || req.user.user_id || req.user.id || -1
            
            return {name: name, id: user_id}
                    
        triggerGenerate: (callback) ->
            @docpad.action 'generate', reset: false, (err) ->
                if err
                    @docpad.log "warn", "GENERATE ERROR"
                else
                    if callback
                        callback()
        
        generateUpdate: (docId,fullPath,callback) ->
            config = @getConfig()

            if config.generateHomePage
                index = @docpad.getCollection('documents').findOne({relativeOutPath: 'index.html'})
                stat = index.getStat()
                stat.mtime = new Date()
                index.setStat(stat)
         
            #check to see if the document already exists ie its an update
            # this is unnecessary as DocPad checks this automatically
            model = @docpad.getCollection(@config.postCollection).findOne({docId: docId})
            
            #if so, load the existing document ready for regeneration
            if model
                model.load()
            else
                #if document doesn't already exist, create it and add to database
                model = @docpad.createModel({fullPath:fullPath})
                model.load()
                @docpad.getDatabase().add(model)

            @triggerGenerate(callback)
         
        
        populateCollections: (opts,next) ->
            docpad = @docpad
            plugin = @
            user = @getUserDetails(null)
            collection = docpad.getCollection(@config.postCollection).findAllLive().forEach (doc) ->
                meta = doc.getAttributes().meta
                if(!meta.docId)
                    meta.content = doc.getContent()
                    meta.user = user
                    plugin.saveDocument(plugin,meta)
      
            next()
        
                                            
        # Use to extend the server with routes that will be triggered before the DocPad routes.
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            docpad = @docpad
            docpadConfig = docpad.getConfig()
            config = @getConfig()
            plugin = @
            sanitize = config.sanitize

            server.get config.loadURL, (req,res,next) ->
 
                docId = parseInt(req.params.docId)
                obj = plugin.loadDocument(docId,plugin)
                if obj.success
                    res.json(obj)
                else
                    res.status(500).json(obj)

                    #next()
            #don't call next as the request stops here because we are serving the document
            
            server.post config.saveURL, (req,res,next) ->

                if req.body.content and req.body.title
                    user = plugin.getUserDetails(req)
                    opts = req.body
                    opts.user = user

                    try
                        plugin.saveDocument plugin,opts,(result) ->
                            if result.success
                                res.json(result)
                            else
                                res.status(500).json(result)
                    catch err
                        return res.status(500).json({success:false, msg: "Error saving document"})
                                                  
                else
                    return res.status(500).json({success:false, msg: 'missing content or title'})
                
            server.post config.generateURL, (req,res,next) ->
                if req.body.docId
                    docId = req.body.docId
                    if typeof docId == "number" and !isNaN(docId)
                        generateUpdate(docId,null,null)
                        res.json({success:true, msg: 'document '+docId+" generated"})
                    else
                        res.status(500).json({success:false, msg: 'docId not a number'})
                else
                    res.status(500).json({success:false, msg: 'docId not a present'})
                    

            @