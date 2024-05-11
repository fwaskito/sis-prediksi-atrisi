/*
* Author		: F. Waskito
* Create on 	: Sat 03 Dec 2022
* Document  	: Triggers
* DBMS			: MySQL
* Server Version: 8.0.31-0ubuntu0.22.04.1 (Ubuntu) 
*/

drop trigger if exists employee__bu;
drop trigger if exists employee__bd;

/*==========================================================
employee before update trigger (to employee history)
-----------------------------------------------------------*/
delimiter //
create trigger employee__bu before update on employee for each row
begin
	delete from employee_history
	where employee_id = old.id
	and mod_action='update'
	and exists (select r_count
				from (select count(*) r_count
						from employee_history
						where employee_id = old.id 
                        and mod_action='update') as t);
    
    insert into employee_history 
		select e.id, 'update', curdate(), "No", e.age, e.department_id, 
				e.dist_from_home, e.edu, e.edu_field, e.env_sat, e.job_sat, 
                e.marital_sts, e.num_comp_worked, e.salary, e.wlb, e.years_at_comp
		from employee as e 
        where e.id = old.id;
end//
delimiter ;

/*==========================================================
employee before delete trigger (to employee history)
-----------------------------------------------------------*/
create trigger employee__bd before delete on employee for each row
    insert into employee_history 
		select e.id, 'delete', curdate(), "Yes", e.age, e.department_id, 
				e.dist_from_home, e.edu, e.edu_field, e.env_sat, e.job_sat, 
                e.marital_sts, e.num_comp_worked, e.salary, e.wlb, e.years_at_comp
		from employee as e 
        where e.id = old.id;


#-------- test --------------------------------------------------
# Copy just the table structure to new table
#---------------------------------------
create table employee_his
like employee;

# Add 3 columns to track deatail histories
#------------------------------
alter table employee_history
modify column employee_id varchar(10) not null,
drop primary key, engine = MyISAM,
	add action varchar(8) default 'insert' first,
    add revision int(6) not null 
		auto_increment after action,
    add dt_datetime datetime not null 
		default current_timestamp after revision,
	add primary key (employee_id, revision);

desc employee_history;

#----------------- Fixed additional column ---------------------------
alter table employee_history
modify column employee_id varchar(10) not null,
drop primary key, engine = InnoDB,
	add mod_action varchar(8) 
		default 'update' after employee_id,
    add mod_date date not null 
		default (current_date) after mod_action,
	add primary key (employee_id, mod_action);

alter table tmp_history
modify column tmp_id varchar(10) not null,
drop primary key, engine = InnoDB,
	add mod_action varchar(8) 
		default 'update' after tmp_id,
    add mod_date date not null 
		default (current_date) after mod_action,
	add primary key (tmp_id, mod_action);



-- New trigger set 'attrition' = null, jika terjadi perubahan (update)
-- dalam bentuk apapun.
drop trigger if exists attrition_set_null__au;

create trigger attrition_set_null__au after update on employee for each row
	set old.attrition = null;



#-----------------------------------------------------
drop trigger if exists tmp__bu;
drop trigger if exists tmp__bd;

delimiter //
create trigger tmp__bu before update on tmp for each row
begin
	delete from tmp_history
	where tmp_id = old.id
	and mod_action='update'
	and exists (select r_count
				from (select count(*) r_count
						from tmp_history
						where tmp_id = old.id 
                        and mod_action='update') as t);
                
    insert into tmp_history 
		select e.id, 'update', curdate(), "No", e.age, e.department_id, 
				e.dist_from_home, e.edu, e.edu_field, e.env_sat, e.job_sat, 
                e.marital_sts, e.num_comp_worked, e.salary, e.wlb, e.years_at_comp
		from tmp as e 
        where e.id = old.id;
end//
delimiter ;

create trigger tmp__bd before delete on tmp for each row
    insert into tmp_history 
		select e.id, 'delete', curdate(), "Yes", e.age, e.department_id, 
				e.dist_from_home, e.edu, e.edu_field, e.env_sat, e.job_sat, 
                e.marital_sts, e.num_comp_worked, e.salary, e.wlb, e.years_at_comp
		from tmp as e 
        where e.id = old.id;


#--------------- Trial and Error ---------------------------
drop trigger if exists employee__ai;
drop trigger if exists employee__bu;
drop trigger if exists employee__bd;

CREATE TRIGGER employee__ai AFTER INSERT ON tmp FOR EACH ROW
    INSERT INTO employee_his SELECT NULL, 'insert', NOW(), d.* 
    FROM tmp AS d WHERE d.employee_id = NEW.employee_id;

CREATE TRIGGER employee__bu BEFORE UPDATE ON tmp FOR EACH ROW
    INSERT INTO employee_his SELECT NULL, 'update', NOW(), d.*
    FROM tmp AS d WHERE d.employee_id = OLD.employee_id;

CREATE TRIGGER employee__bd BEFORE DELETE ON tmp FOR EACH ROW
    INSERT INTO employee_his SELECT NULL, 'delete', NOW(), d.* 
    FROM tmp AS d WHERE d.employee_id = OLD.employee_id;


#----------------------------------------------------
drop trigger if exists employee__bu;
drop trigger if exists employee__bd;

delimiter //
CREATE TRIGGER employee__bu BEFORE UPDATE ON tmp FOR EACH ROW
begin
	delete from employee_his
	where employee_id = OLD.employee_id
	and action='update'
	and exists (select oCount
				from (select count(*) oCount
					from employee_his
					where employee_id=OLD.employee_id and action='update') 
				as t);
    INSERT INTO employee_his SELECT NULL, 'update', NOW(), d.*
    FROM tmp AS d WHERE d.employee_id = OLD.employee_id;
end//
delimiter ;

CREATE TRIGGER employee__bd BEFORE DELETE ON tmp FOR EACH ROW
    INSERT INTO employee_his SELECT NULL, 'delete', NOW(), d.* 
    FROM tmp AS d WHERE d.employee_id = OLD.employee_id;


#---------------------------- Trial and Error - ----------------------
delimiter //
delete from employee_his
where employee_id='ep1475' 
	and action='update'
	and exists (select oCount
				from (select count(*) oCount
					from employee_his
					where employee_id='ep1475' and action='update') 
				as t);
                
insert into employee_his 
	select null, 'update', NOW(), d.* 
    from tmp as d 
    where d.employee_id = 'ep1475';
//
delimiter ;
