var gulp = require('gulp'),
  jade = require('gulp-jade'),
  sass = require('gulp-sass'),
  coffee = require('gulp-coffee'),
  concat = require('gulp-concat'),

  sassPath = './src/sass/**/*.sass',
  coffeePath = './src/coffee/**/*.coffee',
  jadePath = './src/jade/**/*.jade';

gulp

  .task('jade', function() {
    var YOUR_LOCALS = {};

    gulp.src('./src/jade/index.jade')
      .pipe(jade({
        locals: YOUR_LOCALS
      }))
      .pipe(gulp.dest('.'));
  })

  .task('sass', function() {
    gulp.src(sassPath)
      .pipe(sass().on('error', function(error) {
        console.log(error);
      }))
      .pipe(gulp.dest('./assets/css/'));
  })

  .task('coffee', function() {
    gulp.src(coffeePath)
      .pipe(coffee({bare: true}).on('error', function(error) {
        console.log(error);
      }))
      .pipe(gulp.dest('./app/'))
  })

  .task('concat-js', function() {
    gulp.src([
      './node_modules/jquery/dist/jquery.min.js',
      './node_modules/tinymce/tinymce.jquery.min.js',
      './node_modules/tinymce/themes/modern/theme.min.js',
      './node_modules/angular/angular.min.js',
      './node_modules/angular-ui-tinymce/src/tinymce.js',
      './node_modules/malihu-custom-scrollbar-plugin/jquery.mCustomScrollbar.js'
    ])
      .pipe(concat('vendor.js'))
      .pipe(gulp.dest('./app/'))
  })

  .task('watch', function() {
    gulp.watch(sassPath, ['sass']);
    gulp.watch(jadePath, ['jade']);
    gulp.watch(coffeePath, ['coffee']);
  })

  .task('default', [
    'jade',
    'sass',
    'coffee',
    'concat-js',
    'watch'
  ]);


