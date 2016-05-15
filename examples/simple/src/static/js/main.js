/*global $*/
$(function () {
    var editLoader = $('#edit-loader');
    var editMsg = $('#edit-msg');
    var postTitle = $('#post-title');
    var editor = $('#editor');
    var docIdEl = $('#doc-id');
    
    function savePost() {
        editLoader.show();
        var title = postTitle.val();
        var content = editor.val();
        var docIdStr = docIdEl.html();
        var docId = parseInt(docIdStr);

        var obj = {
            content: content,
            title: title
        };
        if ((typeof docId == "number") && (!isNaN(docId))) {
            obj.docId = docId;
        }


        $.post("/save", obj)
            .done(function (data) {
                editMsg.show(); //show a message confirming the save
                editLoader.fadeOut(1000, function () {
                    editMsg.fadeOut(1000);
                });
            })
            .fail(function (xhr, err, msg) {
                editLoader.fadeOut();
                alert(msg);
            });
    }

    function loadPost() {
        var id = $(this).attr('data-id');
        $.get('/load/' + id)
            .done(function (data) {
                postTitle.val(data.title);
                editor.val(data.content);
                docIdEl.text(data.docId);
            });
    }
    
    function createNewPost(){
        var obj = textGenerator();
        postTitle.val(obj.title);
        editor.val(obj.content);
        docIdEl.text("");
    }
    $('.loadBtn').click(loadPost);
    $('#saveBtn').click(savePost);
    $('#generateBtn').click(createNewPost);
});