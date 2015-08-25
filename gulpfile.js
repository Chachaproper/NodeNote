var gulp = require('gulp'),
  jade = require('gulp-jade'),
  sass = require('gulp-sass'),
  coffee = require('gulp-coffee'),

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

  .task('watch', function() {
    gulp.watch(sassPath, ['sass']);
    gulp.watch(jadePath, ['jade']);
    gulp.watch(coffeePath, ['coffee']);
  })

  .task('default', ['jade', 'sass', 'coffee', 'watch']);


