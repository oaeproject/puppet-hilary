
// used by travis-ci to check the hiera json files

var gulp = require("gulp");
var jsonlint = require("gulp-jsonlint");
var expect = require('gulp-expect-file');
var gutil = require('gulp-util');

// custom reporter that should throw exception on lint fail
var myFailReporter = function (file) {
    if (file.jsonlint && !file.jsonlint.success) {
        throw new gutil.PluginError('gulp-jsonlint', 'json lint failed for ' + file.relative);
    }
};

// lint the json files
gulp.task('jsonlint', function() {
    gulp.src("environments/*/hiera/*.json")
        .pipe(jsonlint())
        .pipe(jsonlint.reporter(myFailReporter));
});

// check the secure json files are not included
gulp.task('checksecure', function() {
    // NOTE the first file in the gulp.src array is expected to exist
    // all other files in the array are files we don't want to exist
    gulp.src(["environments/production/hiera/common.json","environments/*/hiera/common_hiera_secure.json","environments/production/modules/localconfig/files/ssl"])
        .pipe(expect('environments/production/hiera/common.json'));
});

// run all tests
gulp.task('default', ['jsonlint','checksecure']);

