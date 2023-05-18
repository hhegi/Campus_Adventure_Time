const express = require('express');
const mdbConn = require('./db/mariaDBConn.js')
const app = express();

const server = app.listen(3000, '192.168.137.1', () =>{
    console.log('server on port 3000');
});

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');
app.engine('html', require('ejs').renderFile);
app.use(express.static('public'));


app.get('/', function(req, res) {
    console.log("adasds");
    res.render('index.html');
})

const loginModule = require('./modules/login')(app);
const withdrawalModule = require('./modules/withdrawal')(app);
const progressModule = require('./modules/myProgress')(app);
const allProgressModule = require('./modules/myCourseProgress')(app);
const myReviewModule = require('./modules/myReviews')(app);
const deleteReviewModule = require('./modules/deleteReview')(app);
const editReviewModule = require('./modules/editReview')(app);
const spotCompleteModule = require('./modules/spotComplete')(app);
const myCompletedCourseModule = require('./modules/myCompletedCourse')(app);
const allCoursesModule = require('./modules/allCourses')(app);