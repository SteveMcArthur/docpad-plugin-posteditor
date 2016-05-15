getDocs = () ->

    [
        {
            title: "My New Document"
            content: "Some content I've written. What do you thing?"
            user : {name: 'johnsmith', user_id: 123456}
            slug: 'my-new-document'
        },{
            title: "Another New Document"
            content: "This is my content. What do you thing?"
            user : {name: 'annsmith', user_id: 789123}
            slug: 'another-new-document'
        }
    ]

module.exports = getDocs()