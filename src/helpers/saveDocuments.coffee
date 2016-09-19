fs = require('safefs')
fileCopy = require('fs-extra').copy
path = require('path')

slugify = (input) ->
    input = input.trim().toLowerCase()
    input = input.replace(/[^a-zA-Z0-9]/g,'-').replace(/^-/,'').replace(/-+/g,'-').trim()
    input = input.replace(/-$/,'').trim()
    return input

getPath = (plugin,title) ->
    defaultSavePath = plugin.getConfig().defaultSavePath
    name = slugify(title)
    return path.join(defaultSavePath,name+'.html.md')

#write new document (after version has been moved to version directory)
writeDocument = (file,fileContent,docObject,plugin,callback) ->
    fs.writeFile file,fileContent, (err) ->
        if err
            callback({success:false, msg:'unable to write document'})
        else
            if plugin.getConfig().handleRegeneration
                plugin.generateUpdate(docObject.docId,file)
            callback(docObject)
            
#move file to version directory
saveVersion = (plugin,file,docId,callback) ->
    dt = new Date()
    mill = dt.getTime().toString()
            
    #version files need to be outside of the document path so
    #they are not generated
    dataPath = plugin.getConfig().dataPath
    #versions stored in folder named after document slug
    copyPath = path.join(dataPath,'versions',docId.toString())
    copyFile = mill+".html.md"
    #ensure docId directory exists in the version dir
    #Doesn't matter if it fails because it exists already
    fs.mkdir copyPath, (err) ->
        fileCopy file,path.join(copyPath,copyFile),(err) ->
            if err
                callback({success:false,msg:'Unable to create version file'})
            callback({success:true,msg:'rename successful'})
                
#merge a documents existing metadata with
#any new metadata
mergeMetaData = (plugin, opts) ->
    docId = opts.docId
    collectionName = plugin.getConfig().postCollection
    docpad = plugin.docpad
    if docId
        document = plugin.findDocument(docId)
        docMeta = document.meta
        for key, val of docMeta
            if !opts[key]
                opts[key] = val
    return {fullPath: document.fullPath,opts: opts}

#make sure arbritrary fields cannot
#be added to a documents metadata
cleanMetadata = (docMeta,opts,plugin) ->
    config = plugin.getConfig()
    customFields = config.customFields
    for key,val of docMeta
        if config.allowableMetadata.indexOf(key) == -1
            delete docMeta[key]
            
    for key,val of customFields
        if opts[key]
            customVal = opts[key]
            docMeta[key] = customVal.replace(titleReg,'').trim()
        
    return docMeta

#build the actual text content of the document, including the metadata section
buildContent = (opts,plugin) ->
   
    docMeta = opts
    config = plugin.getConfig()
    #/[^A-Za-z0-9_.\-~\?!:"'$@# ]/
    titleReg = config.titleReg
    sanitize = config.sanitize
    content = sanitize(opts.content)
    delete docMeta.content
    docMeta.title = docMeta.title.replace(titleReg,'').trim()

    #if we have a slug use that, but make sure it only contains valid characters
    #Otherwise let docpad calculate the slug
    if docMeta.slug
        docMeta.slug = slugify(docMeta.slug)

    if docMeta.tags
        if !Array.isArray(docMeta.tags)
            docMeta.tags = docMeta.tags.split(',')
        for i, val of docMeta.tags
            docMeta.tags[i] = val.replace(titleReg,'').trim()
        
    docMeta.docId = parseInt(docMeta.docId)
    docMeta.layout = docMeta.layout || config.defaultLayout
    docMeta.editdate = (new Date()).toString()
    docMeta.edit_user = docMeta.user.name
    docMeta.edit_user_id = docMeta.user.user_id
    
    if !config.allowArbitraryMetadata
        docMeta = cleanMetadata(docMeta,opts,plugin)
    
    meta = "---\n"
    for prop, val of docMeta
        if Array.isArray(val)
            val = JSON.stringify(val)
        meta += prop+": "+val+"\n"
    meta += "---\n"

    fileContent = meta + content
    docMeta.content = content
    docMeta.success = true

    return {fileContent,docMeta}


checkInteger = (num) ->
    if num is undefined or num is null
        return undefined
    if isNaN(num)
        return undefined
    if !isFinite(num)
        return undefined
    return parseInt(num)

saveDocument = (plugin,opts,callback) ->
   
    callback = callback || () ->
    if !opts.content or !opts.title or !opts.user
        callback({success:false, msg:'missing required fields'})
        return
    opts.docId = checkInteger(opts.docId)
    #need method to ensure that existing documents all have a docId
    if !opts.docId
        #create document
        opts.docId = (new Date()).getTime()
        opts.author =  opts.author || opts.user.name
        opts.creationdate = (new Date()).toString()
        {fileContent,docMeta} = buildContent(opts,plugin)
        fullPath = getPath(plugin,docMeta.title)
        writeDocument(fullPath,fileContent,docMeta,plugin,callback)
    else
        #update document
        {fullPath,opts} = mergeMetaData(plugin, opts)
        {fileContent,docMeta} = buildContent(opts,plugin)
        saveVersion plugin,fullPath,opts.docId,() ->
            writeDocument(fullPath,fileContent,docMeta,plugin,callback)
            
#for testing purposes
methods =
    getPath: getPath
    buildContent: buildContent
    saveVersion: saveVersion
    writeDocument: writeDocument
    mergeMetaData: mergeMetaData
        
module.exports.saveDocument = saveDocument
module.exports.methods = methods