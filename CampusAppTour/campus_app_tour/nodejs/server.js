const express = require('express');
const mdbConn = require('./mariaDBConn.js')
const app = express();

const server = app.listen(3000, () =>{
    console.log('server on port 3000');
});

app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');
app.engine('html', require('ejs').renderFile);

app.get('/', function(req, res) {
    res.render('index.html');
})