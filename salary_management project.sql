create database salary_management;
use salary_management;

create table employee
(
Eid int primary key,
Ename varchar(255),
Gender char(1),
Email varchar(255),
joinDate timestamp
);

select * from employee;

create table salary
(
Sid int primary key,
Basic float,
Allowance float
);

select * from salary;

create table employee_salary
(
Eid int,
Sid int,
foreign key (Eid) references employee(Eid),
foreign key (Sid) references salary(Sid)
);

select * from employee_salary;

create table leave_
(
Lid int primary key,
Eid int,
L_month int,
L_days float,
foreign key (Eid) references employee(Eid)
);

select * from leave_;

create table transection
(
Tid int primary key,
Eid int,
Amount float,
T_date date,
S_month int,
foreign key (Eid) references employee(Eid)
);

select * from transection;

create table fund
(
Fid int primary key,
Fund_amount float 
);

select * from fund;

create table Fund_Audit
(Newfund float primary key,
Oldfund  float,
T_date timestamp
);

select * from fund_audit; 
 
create table EmpSalary_audit
(
Eid int primary key,
NewSid int, 
OldSid int,
ChangingDate timestamp
);

select * from EmpSalary_audit;

alter table salary add column Eid int;

alter table salary add constraint foreign key (Eid) references employee (Eid);


delimiter //
create trigger add_leaves
after insert on transection
for each row 
begin
      update leave_ set l_days = l_days + 1.8 where e_id = new.eid ;
      update leave_ set l_month = new.s_month where e_id = new.eid ;
end
	// delimiter ;


delimiter //
create trigger change_emp_salary
after update on  employee_salary
for each row
begin
     insert into EmpSalary_audit()
     values(new.Eid , new.Sid , old.Sid,now() );
end
   // delimiter ;  
   
   
   delimiter //
create trigger AddEmp 
before update on employee
for each row 
begin 
     insert into employee(EID , Ename, Gender , Email, joinDate)
     values(new.Ename , new.Gender , new.Email ,now()) ;
     
end ; 
// delimiter  ; 


delimiter //
create trigger AddEmpSalary
after insert on employee_salary
for each row 
begin 
     insert into empsalary_audit()
     values(new.EID,new.sid ,"New Employee",now());
end ;
// delimiter ; 


delimiter //
create trigger  Transect
after insert on transection
for each row 
begin 
     update fund set fund_amount = fund_amount - new.Amount where FID=1 ;
end ; 
// delimiter ;


delimiter //
create trigger  UpdateFund
after update on fund 
for each row 
begin 
     insert into fund_audit()
     value(new.fund_amount , old.fund_amount , now() ) ; 
end ;
// delimiter ;


delimiter //
create procedure  View_Details (employee_id int )
begin 
select employee.EID,
employee_salary.SID ,
employee.ename ,
 employee.gender , 
 employee.JoinDate ,
 salary.Basic,
 salary.allowance ,
 transection.amount ,
 transection.s_month , 
 transection.t_date ,
 employee.email from employee
 join employee_salary 
 on employee.EID = employee_salary.EID 
 join salary 
 on employee.EID = salary.eid
 join transection 
 on  employee.eid = transection.eid where employee.eid = employee_id ;
end ;
// delimiter ;



delimiter //
create function generatesalary(id int , month int )
returns float
deterministic reads 
sql data 
begin 
	 declare basics float;     
	 declare allowances float;
	 declare l_day_ float ;
	 declare salary int ;
      
	select basic into basics from salary where eid = id  ;
	select allowance into allowances from salary where eid = id ;
	select l_day into l_day_ from leave_ where l_month = month ;
	set salary = basics + allowances * (30-l_day_) ;
	return salary ;
end ; 
// delimiter ;

delimiter //

create function checkvalid (eid int , month int ) 
returns int
deterministic reads sql data 
begin 
     declare pay_count  int ;
     declare result int ;
     
     select count(*) into  pay_count from transection  where eid =eid and s_month = month ;
     
     if paycount >0 then 
	     set result = 1 ;
     else 
         set result =2 ;
     end if ;
     return result ;
end ;
// delimiter ;    


delimiter //
create procedure changeemppos(id int , ids int )
begin
    update employee_salary set sid = ids where eid = id ; 
end ;
// delimiter ;     



delimiter //
create procedure AddEmployee(eid int , Name_  varchar(255), gender char(1), email varchar(255), joiningDate timestamp, SID int ) 
begin
     insert into employee() 
     values(eid , name_ , gender , email , joiningdate ) ;
     insert into employee_salary()
     values(eid , sid ); 
end ;
// delimiter ;     


delimiter //
create procedure update_fund(amounts  float  , id int )
begin 
     update fund set fund_amount  = fund_amount - amounts where fid = id   ;
end ; 
// delimiter ; 


delimiter // 
create procedure transectsalary(in eid int , in amount float  , in month int, in fid int  )
begin 
     if    checkvalid(eid , month ) then 
           call update_fund(amount,fid);
           
           insert into transection(eid,amount,t_date,s_month)
           values(eid,amount, now(), month);
           
     else 
		  select "transection invalid salary already given " ;
     
     end IF ;
end ; 
// delimiter ;       


    
delimiter //
create procedure add_leave(lid_ int ,eid_ int  , l_month_ int , leave_days float  )
begin 

     insert into leave_(lid , eid , l_month , l_days )
     values(lid_ , eid_ ,  l_month_ , leave_days ) ;
end ; 
// delimiter ;    

delimiter // 
create procedure add_fund(id int , amount  float  )
begin 
     update fund set fund_amount = fund_amount + amount where fid = id ; 
end ; 
// delimiter ; 


delimiter //
create procedure paysalary(in eid int ,  in  s_month int , in fid int )     

begin 
     declare salary float ; 
     set salary = generatesalary(eid,s_month);
     
     call transectsalary(eid , salary , s_month , fid );
     
     select "SalaryPaid" as status_, amount as amount_paid from transection 
     where eid = eid  and month = s_month ;
end ;
// delimiter ;    












   
   
















