/*
 * Copyright 2015 Apereo Foundation (AF) Licensed under the
 * Educational Community License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License. You may
 * obtain a copy of the License at
 *
 *     http://opensource.org/licenses/ECL-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an "AS IS"
 * BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

// used by travis-ci to check the hiera json files

var expect = require('gulp-expect-file');
var gulp = require("gulp");
var gutil = require('gulp-util');
var jsonlint = require("gulp-jsonlint");

// custom reporter that should throw exception on lint fail
var myFailReporter = function(file) {
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

