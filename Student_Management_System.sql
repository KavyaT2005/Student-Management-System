-- Database: students
CREATE DATABASE IF NOT EXISTS students;
USE students;

-- Drop if existing (for clean start)
DROP TABLE IF EXISTS attendence, department, student, test, trig, user;

-- Table: attendence
CREATE TABLE attendence (
  aid int(11) NOT NULL AUTO_INCREMENT,
  rollno varchar(20) NOT NULL,
  attendance int(100) NOT NULL,
  PRIMARY KEY (aid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO attendence (aid, rollno, attendance) VALUES
(6, '1ve17cs012', 98);

-- Table: department
CREATE TABLE department (
  cid int(11) NOT NULL AUTO_INCREMENT,
  branch varchar(50) NOT NULL,
  PRIMARY KEY (cid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO department (cid, branch) VALUES
(2, 'Information Science'),
(3, 'Electronic and Communication'),
(4, 'Electrical & Electronic'),
(5, 'Civil '),
(7, 'computer science'),
(8, 'IOT');

-- Table: student
CREATE TABLE student (
  id int(11) NOT NULL AUTO_INCREMENT,
  rollno varchar(20) NOT NULL,
  sname varchar(50) NOT NULL,
  sem int(20) NOT NULL,
  gender varchar(50) NOT NULL,
  branch varchar(50) NOT NULL,
  email varchar(50) NOT NULL,
  number varchar(12) NOT NULL,
  address text NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: trig (for logs)
CREATE TABLE trig (
  tid int(11) NOT NULL AUTO_INCREMENT,
  rollno varchar(50) NOT NULL,
  action varchar(50) NOT NULL,
  timestamp datetime NOT NULL,
  PRIMARY KEY (tid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Triggers
DELIMITER $$

CREATE TRIGGER Insert AFTER INSERT ON student
FOR EACH ROW
BEGIN
  INSERT INTO trig VALUES (NULL, NEW.rollno, 'STUDENT INSERTED', NOW());
END$$

CREATE TRIGGER UPDATE AFTER UPDATE ON student
FOR EACH ROW
BEGIN
  INSERT INTO trig VALUES (NULL, NEW.rollno, 'STUDENT UPDATED', NOW());
END$$

CREATE TRIGGER DELETE BEFORE DELETE ON student
FOR EACH ROW
BEGIN
  INSERT INTO trig VALUES (NULL, OLD.rollno, 'STUDENT DELETED', NOW());
END$$

DELIMITER ;

-- Table: test
CREATE TABLE test (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(52) NOT NULL,
  email varchar(50) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO test (id, name, email) VALUES
(1, 'aaa', 'aaa@gmail.com');

-- Table: user
CREATE TABLE user (
  id int(11) NOT NULL AUTO_INCREMENT,
  username varchar(50) NOT NULL,
  email varchar(50) NOT NULL,
  password varchar(500) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO user (id, username, email, password) VALUES
(4, 'anees', 'anees@gmail.com', 'pbkdf2:sha256:150000$1CSLss89$ef995dfc48121768b2070bfbe7a568871cd56fac85ac7c95a1e645c8806146e9');

-- Stored Procedures
DELIMITER $$

-- Insert new student
CREATE PROCEDURE InsertStudent(
    IN p_rollno VARCHAR(20),
    IN p_sname VARCHAR(50),
    IN p_sem INT,
    IN p_gender VARCHAR(50),
    IN p_branch VARCHAR(50),
    IN p_email VARCHAR(50),
    IN p_number VARCHAR(12),
    IN p_address TEXT
)
BEGIN
    INSERT INTO student (rollno, sname, sem, gender, branch, email, number, address)
    VALUES (p_rollno, p_sname, p_sem, p_gender, p_branch, p_email, p_number, p_address);
END$$

-- Get attendance by roll number
CREATE PROCEDURE GetAttendance(
    IN p_rollno VARCHAR(20)
)
BEGIN
    SELECT * FROM attendence WHERE rollno = p_rollno;
END$$

-- Delete a student by rollno (triggers deletion log)
CREATE PROCEDURE DeleteStudent(
    IN p_rollno VARCHAR(20)
)
BEGIN
    DELETE FROM student WHERE rollno = p_rollno;
END$$

-- Get all students of a specific branch
CREATE PROCEDURE GetStudentsByBranch(
    IN p_branch VARCHAR(50)
)
BEGIN
    SELECT * FROM student WHERE branch = p_branch;
END$$

DELIMITER ;

-- Example procedure usage
-- (Uncomment these to test in your DBMS)

-- CALL InsertStudent('1ve17cs999', 'Ravi', 6, 'Male', 'computer science', 'ravi@example.com', '9999999999', '123 Main St');
-- CALL GetAttendance('1ve17cs012');
-- CALL DeleteStudent('1ve17cs999');
-- CALL GetStudentsByBranch('computer science');