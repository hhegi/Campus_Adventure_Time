const mariadb = require('mariadb');
const vals = require('./config/consts.js');

const mysql = require('mysql2/promise');

async function createUserTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
      CREATE TABLE user (
        idx INT AUTO_INCREMENT PRIMARY KEY,
        user_name VARCHAR(50) NOT NULL,
        user_nickname VARCHAR(50) NOT NULL,
        user_email VARCHAR(100) UNIQUE NOT NULL,
        access_token VARCHAR(500) NOT NULL,
        refresh_token VARCHAR(500) NOT NULL
      )
    `);
    console.log('user table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}

async function createCourseTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5,
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
      CREATE TABLE course (
        idx INT AUTO_INCREMENT PRIMARY KEY,
        course_name VARCHAR(50) NOT NULL,
        course_spots TEXT NOT NULL,
        course_description TEXT
      )
    `);
    console.log('course table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}

async function createSpotTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5,
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
      CREATE TABLE spot (
        idx INT AUTO_INCREMENT PRIMARY KEY,
        course_idx INT NOT NULL,
        spot_name VARCHAR(50) NOT NULL,
        spot_coordinate POINT NOT NULL,
        spot_image TEXT,
        spot_description TEXT,
        FOREIGN KEY (course_idx) REFERENCES course(idx) ON UPDATE CASCADE ON DELETE CASCADE
      )
    `);
    console.log('spot table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}

async function createProgressTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5,
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
      CREATE TABLE progress (
        idx INT AUTO_INCREMENT PRIMARY KEY,
        course_idx INT NOT NULL,
        user_idx INT NOT NULL,
        spot_completed TEXT,
        is_completed TINYINT(1) DEFAULT 0,
        start_time DATETIME NOT NULL,
        end_time DATETIME,
        FOREIGN KEY (course_idx) REFERENCES course(idx) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY (user_idx) REFERENCES user(idx) ON UPDATE CASCADE ON DELETE CASCADE
      )
    `);
    console.log('progress table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}
async function createReviewTable() {
  const connection = await mysql.createConnection({
    host: vals.DBHost,
    port: vals.DBPort,
    user: vals.DBUser,
    password: vals.DBPass,
    connectionLimit: 5,
  });

  try {
    await connection.query("USE campus_app_tour;");
    await connection.query(`
  CREATE TABLE review (
    idx INT AUTO_INCREMENT PRIMARY KEY,
    review_title VARCHAR(50),
    review_content TEXT NOT NULL,
    grade FLOAT NOT NULL,
    course_idx INT NOT NULL,
    user_idx INT NOT NULL,
    FOREIGN KEY (course_idx) REFERENCES course(idx) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (user_idx) REFERENCES user(idx) ON UPDATE CASCADE ON DELETE CASCADE
  )
`);
    console.log('review table created successfully');
  } catch (err) {
    console.error(err);
  } finally {
    connection.end();
  }
}

createUserTable();
createCourseTable();
createSpotTable();
createProgressTable();
createReviewTable();

// module.exports = {
//     getUserList: GetUserList
// }