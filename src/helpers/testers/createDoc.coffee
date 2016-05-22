fs = require('safefs')
util = require('util')
path = require('path')

createDoc = (tester) ->
    outfile = path.join(tester.config.testPath, 'src', 'documents','posts','bacon-prosciutto.html.md')

    meta = "---\n"+
        "docId: 1262200515233\n"+
        "title: Bacon Prosciutto\n"+
        "slug: posts-bacon-prosciutto\n"+
        "layout: post\n"+
        "---\n"
    content = meta +
        "Bacon ipsum dolor amet chuck porchetta tri-tip meatball spare ribs, picanha prosciutto rump tail beef. Salami pancetta ham short loin short ribs, landjaeger pork. Jowl turducken landjaeger, tri-tip kielbasa shank swine venison filet mignon flank sausage andouille. Leberkas short loin rump chuck bacon. Ham hock pork loin hamburger tri-tip porchetta drumstick.\n\n"
        "Pancetta pastrami salami brisket tongue, pork chop flank tri-tip pork chuck swine. Venison drumstick pig, sausage alcatra prosciutto strip steak. Landjaeger brisket tail, salami sausage pork belly fatback turducken spare ribs shankle strip steak sirloin chuck meatball doner. Meatball pork brisket, bacon cow salami bresaola biltong beef ribs tongue jowl tenderloin frankfurter.\n"
    
    fs.writeFileSync(outfile,content,'utf-8')
    
module.exports = createDoc