# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON

docpadConfig =

    templateData:

        site:
            url: "http://localhost"
            title: "Your Website"
            description: """
                When your website appears in search results in say Google, the text here will be shown underneath your website's title.
                """
            keywords: """
                place, your, website, keywoards, here, keep, them, related, to, the, content, of, your, website
                """
        getPreparedTitle: ->
            # if we have a document title, then we should use that and suffix the site's title onto it
            if @document.title
                "#{@document.title} | #{@site.title}"
            # if our document does not have it's own title, then we should just use the site's title
            else
                @site.title
        getPreparedDescription: ->
            # if we have a document description, then we should use that, otherwise use the site's description
            @document.description or @site.description
        getPreparedKeywords: ->
            # Merge the document keywords with the site keywords
            @site.keywords.concat(@document.keywords or []).join(', ')
    collections:
        posts: ->
            @getCollection('documents').findAllLive({relativeOutDirPath: 'posts'})
    plugins:  # example
        posteditor:
            handleRegeneration: false
            generateHomePage: true
            sendRenderedContent: false

    events:
        serverExtend: (opts) ->
            cfg = @docpad.getConfig()
            console.log("serverExtend")
            console.log(cfg.port)


# Export our DocPad Configuration
module.exports = docpadConfig