loadDocument = (docId,plugin,slug) ->
    docpad = plugin.docpad
    config = plugin.getConfig()

    try
        document = plugin.findDocument(docId,slug)
    catch err
        return {success:false, msg: "couldn't find document",err:err}

    try
        if document
            tags = document.meta.tags or []
            if typeof tags is 'string'
                tags = [tags]
            content = document.content
            if config.sendRenderedContent
                content = document.contentRenderedWithoutLayouts

            obj =
                docId: docId
                title: document.title
                date: document.date
                content: content
                slug: document.slug
                editdate: document.editdate
                tags: tags
                img: document.img
                success: true

            config.customFields.forEach (item) ->
                obj[item] = document[item]

            return obj
        else
            return {success:false, msg: "couldn't find document"}
    catch err
        return {success:false, msg: "couldn't find document",err: err}

        
    
    
module.exports = loadDocument