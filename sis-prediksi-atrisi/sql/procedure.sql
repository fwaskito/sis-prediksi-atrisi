/*
* Author		: F. Waskito
* Create on 	: Sat 03 Dec 2022
* Document  	: Procedures
* DBMS			: MySQL
* Server Version: 8.0.31-0ubuntu0.22.04.1 (Ubuntu) 
*/

drop procedure if exists get_employees;
drop procedure if exists get_employees_history;
drop procedure if exists get_test_data;
drop procedure if exists get_train_data;
drop procedure if exists get_all_train_data;
drop procedure if exists get_train_data_distribution;
drop procedure if exists set_attrition_null;

/*==========================================================
get employees procedure
-----------------------------------------------------------*/
delimiter //
create procedure get_employees(
)
begin
	select t1.id, attrition, age, name as department_name, 
		dist_from_home, edu, edu_field, env_sat, job_sat, 
        marital_sts, num_comp_worked, salary, wlb, years_at_comp
	from employee t1
	inner join department t2
		on t1.department_id = t2.id
	order by t1.id;
end//
delimiter ;

/*==========================================================
get employees history procedure
-----------------------------------------------------------*/
delimiter //
create procedure get_employees_history(
)
begin
	select employee_id, attrition, age, name as department_name, 
		dist_from_home, edu, edu_field, env_sat, job_sat, 
        marital_sts, num_comp_worked, salary, wlb, years_at_comp,
        mod_action, mod_date
	from employee_history t1
	inner join department t2
		on t1.department_id = t2.id
	order by employee_id;
end//
delimiter ;

/*==========================================================
get tes data procedure
-----------------------------------------------------------*/
delimiter //
create procedure get_test_data(
)
begin
	select t1.id, attrition, age, name as department_name, 
		dist_from_home, edu, edu_field, env_sat, job_sat, 
        marital_sts, num_comp_worked, salary, wlb, years_at_comp
	from employee t1
	inner join department t2
		on t1.department_id = t2.id
	where attrition is null
	order by t1.id;
end//
delimiter ;

/*==========================================================
get train data procedure
-----------------------------------------------------------*/
delimiter //
create procedure get_train_data(
)
begin
	select employee_id, attrition, age, name as department_name, 
		dist_from_home, edu, edu_field, env_sat, job_sat, 
        marital_sts, num_comp_worked, salary, wlb, years_at_comp
	from employee_history t1
	inner join department t2
		on t1.department_id = t2.id
	where t1.employee_id = employee_id
		and t1.mod_action=(case when (select count(*)
									from employee_history
									where employee_id = t1.employee_id 
										and mod_action='delete'
									) = 1
									then 'delete'
								else 'update'
							end)
	order by employee_id;
end//
delimiter ;

/*==========================================================
get train data distribution procedure
-----------------------------------------------------------*/
delimiter //
create procedure get_train_data_distribution(
)
begin
	select count(*) total_data,
		   count(if(attrition='Yes', 1, null)) class_yes,
		   count(if(attrition='No', 1, null)) class_no
	from employee_history;
end//
delimiter ;

/*==========================================================
get all train data procedure
-----------------------------------------------------------*/
delimiter //
create procedure get_all_train_data(
)
begin
	select employee_id, attrition, age, name as department_name, 
		dist_from_home, edu, edu_field, env_sat, job_sat, 
        marital_sts, num_comp_worked, salary, wlb, years_at_comp
	from employee_history t1
	inner join department t2
		on t1.department_id = t2.id
	order by employee_id;
end//
delimiter ;

/*==========================================================
set attrition null procedure
-----------------------------------------------------------*/
delimiter //
create procedure set_attrition_null(
	in p_id VARCHAR(10)
)
begin
	update employee
    set attrition = null
    where id = p_id;
end//
delimiter ;

#------- test ---------------------------------------------
call get_train_data();
call get_employees();
