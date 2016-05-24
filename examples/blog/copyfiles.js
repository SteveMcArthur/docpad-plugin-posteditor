/*global require,__dirname*/
var fs = require('fs');
var path = require('path')

function copyFile(source, target, cb) {
    var cbCalled = false;
    cb = cb || function(){};

    var rd = fs.createReadStream(source);
    rd.on("error", function (err) {
        done(err);
    });
    var wr = fs.createWriteStream(target);
    wr.on("error", function (err) {
        done(err);
    });
    wr.on("close", function () {
        done();
    });
    rd.pipe(wr);

    function done(err) {
        if (!cbCalled) {
            cb(err);
            cbCalled = true;
        }
    }
}

function getFiles(inputPath) {
    var items = fs.readdirSync(inputPath);
    var files = items.map(function (name) {
        var file = path.join(inputPath, name);
        var stat = fs.statSync(file);
        if (stat.isFile()) {
            return file;
        }

    });
    return files;
}

var inputPath = path.resolve(__dirname, 'testfiles');
var outPath = path.resolve(__dirname, 'src', 'render', 'posts');

var files = getFiles(inputPath)
files.forEach(function (file) {
    var name = path.basename(file);
    var target = path.join(outPath, name);
    console.log(target);
    copyFile(file,target);
})