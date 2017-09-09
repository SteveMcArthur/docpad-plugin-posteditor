
# Test our plugin using DocPad's Testers
pathUtil = require('path')
testerBase =
    pluginPath: __dirname+'/..'
    autoExit: 'safe'
    pluginName: 'posteditor'

getTesterConfig = (name) ->
    config = JSON.parse(JSON.stringify(testerBase))
    config.testerPath = pathUtil.join('out','helpers','testers', name+".tester.js")
    return config
docpadConfig =
    regenerateDelay: 100
    plugins:
        posteditor:
            handleRegeneration: true
            generateHomePage: true
            sendRenderedContent: false

require('docpad').require('testers')
    #.test(getTesterConfig('generate'),docpadConfig)
    #.test(getTesterConfig('properties-exist'),docpadConfig)
    #.test(getTesterConfig('createPaths'),docpadConfig)
    #.test(getTesterConfig('loaddocument'),docpadConfig)
    #.test(getTesterConfig('savedocument'),docpadConfig)
    #.test(getTesterConfig('request'),docpadConfig)
    #.test(getTesterConfig('regeneration'),docpadConfig)
    #.test(getTesterConfig('sanity-check'),docpadConfig)
    .test(getTesterConfig('stress'),docpadConfig)