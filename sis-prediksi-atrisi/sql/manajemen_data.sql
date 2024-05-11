/*
* Author		: F. Waskito
* Create on 	: Sat 03 Dec 2022
* Document  	: Management data - SPPK
* DBMS			: MySQL
* Server Version: 8.0.31-0ubuntu0.22.04.1 (Ubuntu) 
*/

/*==============================================================
Impor data dari file .csv
--------------------------------------------------------------*/
LOAD DATA INFILE '/var/lib/mysql-files/ibm-attrition-dataset2.csv'
INTO TABLE employee
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/*=============================================================
Table utama
--------------------------------------------------------------*/
CREATE TABLE department (
	id VARCHAR(10) NOT NULL,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
); -- ENGINE=INNODB

INSERT INTO department
VALUES (
	'DP1',
    'Research & Development'
);

#-----------------------------------
CREATE TABLE employee (
	id VARCHAR(10) NOT NULL,
    attrition VARCHAR(5),
	age INT NOT NULL,
    department_id VARCHAR(50) NOT NULL,
    dist_from_home INT NOT NULL,		-- distance from home
    edu INT NOT NULL,					-- education
    edu_field VARCHAR(50) NOT NULL,	-- education field
    env_sat INT NOT NULL,				-- environment satisfaction
    job_sat INT NOT NULL,				-- job satisfaction
    marital_sts VARCHAR(10) NOT NULL,	-- marital status
    num_comp_worked INT NOT NULL,		-- number companies worked
    salary INT NOT NULL, 				-- monthly income
    wlb INT NOT NULL, 					-- work life balance
    years_at_comp INT NOT NULL,			-- years at company
	PRIMARY KEY (id)
); -- ENGINE=INNODB

SET SQL_SAFE_UPDATES=0;

UPDATE employee
SET department_id = 'DP3'
WHERE department_id = 'Human Resources';

ALTER TABLE employee
MODIFY department_id VARCHAR(10) NOT NULL;

#--pastika trigger terpasang--------------

DELETE FROM employee
WHERE attrition = 'Yes';

ALTER TABLE employee
MODIFY department_id VARCHAR(10) NOT NULL,
ADD CONSTRAINT fk_employee_department_id
    FOREIGN KEY (department_id)
		REFERENCES department(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE;
#-----------------------------------------------



-- collation character set for table and column
ALTER TABLE user
CHARACTER SET utf8mb4 
COLLATE utf8mb4_0900_ai_ci;

ALTER TABLE user
MODIFY password VARCHAR(100) CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci NOT NULL;

ALTER TABLE employee_history
MODIFY mod_date date NOT NULL;

#-----------------------------------
CREATE TABLE employee_history (
	employee_id VARCHAR(10) NOT NULL,
    attrition VARCHAR(5) NOT NULL,
	age INT NOT NULL,
    department_id VARCHAR(10) NOT NULL,
    dist_from_home INT NOT NULL,
    edu INT NOT NULL,
    edu_field VARCHAR(50) NOT NULL,
    env_sat INT NOT NULL,
    job_Sat INT NOT NULL,
    marital_sts VARCHAR(10) NOT NULL,
    num_comp_worked INT NOT NULL,
    salary INT NOT NULL,
    wlb INT NOT NULL,
    years_at_comp INT NOT NULL,
	PRIMARY KEY (employee_id),
	CONSTRAINT fk_employee_history_department_id
    FOREIGN KEY (department_id)
		REFERENCES department(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

ALTER TABLE employee_history
	CHANGE employee_id employee_id VARCHAR(10) NOT NULL,
	DROP PRIMARY KEY,
	ADD mod_action VARCHAR(8)
		DEFAULT 'update' 
        AFTER employee_id,
	ADD mod_date DATE NOT NULL
        AFTER mod_action,
	ADD PRIMARY KEY (employee_id, mod_action);

#-----------------------------------
CREATE TABLE user (
	id VARCHAR(10) NOT NULL,
    name VARCHAR(50) NOT NULL,
    type VARCHAR(10) NOT NULL,
    username VARCHAR(15) NOT NULL,
    password VARCHAR(25) NOT NULL,
    PRIMARY KEY (id)
);

INSERT INTO user
VALUES (
	'US1',
    'Fajar Waskito',
    'admin',
    'fwaskito',
    'fwaskito123'
);
/*=============================================================
Table simulasi
--------------------------------------------------------------*/
CREATE TABLE tmp (
	id VARCHAR(10) NOT NULL,
    attrition VARCHAR(5) NOT NULL,
	age INT NOT NULL,
    department_id VARCHAR(50) NOT NULL,
    dist_from_home INT NOT NULL,
    edu INT NOT NULL,
    edu_field VARCHAR(100) NOT NULL,
    env_sat INT NOT NULL,
    job_Sat INT NOT NULL,
    marital_sts VARCHAR(10) NOT NULL,
    num_comp_worked INT NOT NULL,
    salary INT NOT NULL,
    wlb INT NOT NULL,
    years_at_comp INT NOT NULL,
	PRIMARY KEY (id)
);

UPDATE tmp
SET department_id = 'DP3'
WHERE department_id = 'Human Resources';
    
ALTER TABLE tmp
MODIFY department_id VARCHAR(10) NOT NULL,
ADD CONSTRAINT fk_tmp_department_id
    FOREIGN KEY (department_id)
		REFERENCES department(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE;
        
#---------------------------------------
CREATE TABLE tmp_history (
	tmp_id VARCHAR(10) NOT NULL,
    attrition VARCHAR(5) NOT NULL,
	age INT NOT NULL,
    department_id VARCHAR(10) NOT NULL,
    dist_from_home INT NOT NULL,
    edu INT NOT NULL,
    edu_field VARCHAR(100) NOT NULL,
    env_sat INT NOT NULL,
    job_Sat INT NOT NULL,
    marital_sts VARCHAR(10) NOT NULL,
    num_comp_worked INT NOT NULL,
    salary INT NOT NULL,
    wlb INT NOT NULL,
    years_at_comp INT NOT NULL,
	PRIMARY KEY (tmp_id),
	CONSTRAINT fk_tmp_history_department_id
    FOREIGN KEY (department_id)
		REFERENCES department(id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

ALTER TABLE tmp_history
	CHANGE id tmp_id VARCHAR(10) NOT NULL,
	DROP PRIMARY KEY,
	ENGINE = InnoDB,
	ADD mod_action VARCHAR(8)
		DEFAULT 'update' 
        AFTER tmp_id,
	ADD mod_date DATE NOT NULL
		DEFAULT (CURRENT_DATE) 
        AFTER mod_action,
	ADD PRIMARY KEY (employee_id, mod_action);

/*=============================================================
Drop Foreign Key
--------------------------------------------------------------*/
ALTER TABLE employee_history
DROP FOREIGN KEY fk_employee_history_department_id;

-- Remove index (because simply removing fk doesn't remore the index)
ALTER TABLE employee_history
DROP INDEX fk_employee_history_department_id;


SET SQL_SAFE_UPDATES=0;
/*Apabila telah terjadi perubahan data menyeluruh di masa mendatang.
*/
# penyebab misalnya,
# untuk seluruh karyawan
UPDATE employee
SET salary = salary * (1-(10/100)),  -- gaji dipotong 10%
	job_sat = job_sat - 1,			 -- & penurunan kepusan kerja
	attrition = null;









