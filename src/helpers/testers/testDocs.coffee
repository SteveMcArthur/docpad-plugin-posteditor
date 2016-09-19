getDocs = () ->

    obj =
    [
        {
            title: "My New Document"
            content: "Some content I've written. What do you thing?"
            author: "John Smith"
            user : {name: 'johnsmith', user_id: 123456}
            slug: 'my-new-document'
        },{
            title: "Another New Document"
            content: "This is my content. What do you thing?"
            author: "Ann Smith"
            user : {name: 'annsmith', user_id: 789123}
            slug: 'another-new-document'
        }
    ]

    return JSON.parse(JSON.stringify(obj))


module.exports = getDocs()