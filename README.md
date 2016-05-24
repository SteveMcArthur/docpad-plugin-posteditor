# Post Editor Plugin for [DocPad](http://docpad.org)

[![Build Status](https://img.shields.io/travis/SteveMcArthur/docpad-plugin-posteditor/master.svg)](https://travis-ci.org/SteveMcArthur/docpad-plugin-posteditor "Check this project's build status on TravisCI")
[![NPM version](https://img.shields.io/npm/v/docpad-plugin-posteditor.svg)](https://www.npmjs.com/package/docpad-plugin-posteditor "View this project on NPM")
[![NPM downloads](https://img.shields.io/npm/dm/docpad-plugin-posteditor.svg)](https://www.npmjs.com/package/docpad-plugin-posteditor "View this project on NPM")


Docpad plugin that allows the saving and updating of posts/articles. It provides the basis for an admin/CMS interface. 

![Screen shot](https://raw.githubusercontent.com/SteveMcArthur/docpad-plugin-posteditor/master/screenshot.jpg)

It manages the saving and updating of posts and loading of existing posts for an editor interface. It does not provide the editor interface. It is editor interface agnostic. It assumes you have provided an editor on the client side with client code to request existing articles via the plugin's configured load url and save articles via the configured save url. The editor can be a simple textarea element or a full-blown text editor like [CKeditor](http://ckeditor.com/). The choice is yours.

The plugin will also save old versions of an article to a "versions" folder - thus maintaining a history of each post edited. 

The plugin also (optionally) manually triggers the regeneration of a saved article and the home page. This is especially useful if you want to stop Docpad from regenerating the whole website on each save. It is also particularly relevant if you are storing articles and documents outside of the Docpad root/repo.

The plugin is designed to work with an existing authentication/login system - although it will work without any authentication as well. In truth, it is built to work in tandem with my other plugin, [docpad-plugin-authentication](https://github.com/SteveMcArthur/docpad-plugin-authentication). User name and user id is added to the metadata of the document saved.

### Default configuration
```coffee
    config:
        #custom metadata fields outside of the standard title,layout and tags.
        #Prevents the arbitrary addition of extra (unexpected) metadata fields.
        #A validation of user input.
        customFields: []
        #Location for version files. This also needs to be outside of the
        #docpad src folder so that version files are not generated or copied to the
        #out folder
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
        titleReg: /[^A-Za-z0-9_.\-~\?! ]/g
```

### Example JS for loading an article/post

```js
    function getPost(docId,slug) {
        var id = docId ? docId : slug;
        $.get('/load/' + id)
            .done(function (data) {
                $('#post-title').val(data.title);
                $('#slug').text(data.slug);
                $('#feature-img').attr('src', data.img);
                $('#docId').text(data.docId);
                var tags = $('#tags');
                for (var i = 0; i < data.tags.length; i++) {
                    tags.append('<li><a class="icon-cancel-circle"></a>' + data.tags[i] + "</li>");
                }

                CKEDITOR.instances.editor1.setData(data.content, {
                    callback: function () {
                        var btn = $('.cke_voice_label:contains("save")').parent();
                        btn.addClass('save-btn');
                    }
                });

            });
    }
```

### Example JS for saving an article/post
```js
    function postData() {
        var txt = downshow(CKEDITOR.instances.editor1.getData());
        var title = $('#post-title').val();
        var slug = $('#slug').text();
        var docId = parseInt($('#docId').text());
        var inputs = $('#tags li');
        var tags = [];
        inputs.each(function () {
            tags.push($(this).text());
        });

        //check we actually have something written
        //and that we have a title
        if (txt.length < 10) {
            alert("Write something first!");
        } else if (title.length < 2) {
            $('#title-callout').fadeIn();
            var titleCallout = function () {
                $('#title-callout').fadeOut();
                $(this).unbind('click', titleCallout);
            };
            $('#post-title').click(titleCallout);


        } else {
            $('#edit-loader').show();

            var obj = {
                content: txt,
                title: title,
                slug: slug,
                tags: tags,
                docId: docId
            };

            $.post('/save', obj)
                .done(function () {
                    $('#edit-msg').show();
                    $('#edit-loader').fadeOut(1000, function () {
                        $('#edit-msg').fadeOut(1000);
                    });
                })
                .fail(function (xhr, err, msg) {
                    $('#edit-loader').fadeOut(500);
                    $('#edit-msg').fadeOut(500);
                    alert(msg);
                });
        }

    }

```

## Regeneration of saved posts
The plugin works by saving edited or new articles/posts directly to the file system. It then uses Docpad's inbuilt system for regenerating a page when the corresponding source file is modified. To give finer control over the regeneration process the plugin will manually trigger the regeneration of the document just updated. This works best when Docpad is run with the `docpad server` command rather than `docpad run`, otherwise the regeneration process will run twice. If you want docpad to handle all regeneration on its own (as normal), then set the config option `handleRegeneration: false`.

## Converting HTML to Markdown
The plugin expects [Markdown](http://daringfireball.net/projects/markdown/) to be sent to the server. Typically, however, the general user will not know Markdown. Fair enough. So typically 'wiswyg' editors (like CKeditor) will work with HTML. So, to facilitate this, the plugin will send the rendered content (ie HTML) to the client. To send the content back to the server we need to convert the HTML back to Markdown. To do this I use the [Downshow](https://github.com/acornejo/downshow) js library.



## License

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT license](http://creativecommons.org/licenses/MIT/)

Copyright &copy; 2016+ Steve McArthur <steve@stevemcarthur.co.uk> (http://www.stevemcarthur.co.uk)
