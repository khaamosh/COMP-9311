-- comp9311 19T3 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(unswid, longname)
as
--... SQL statements, possibly using other views/functions defined by you ...
select distinct(unswid),longname from rooms where id IN(select room from room_facilities where facility = ( select id from facilities where description = 'Air-conditioned'));
;

-- Q2:
create or replace view Q2(unswid,name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select distinct  unswid,name from people where id in (select id from staff where id in ( select staff from course_staff where course in ( select distinct(course) from course_enrolments  where student = ( select id from People where name = 'Hemma Margareta' ) ) ) );
;

-- Q3:

create or replace view test5(id,semester)
as
select id,semester from courses where subject in ( select id from subjects where code = 'COMP9311');
;

create or replace view test6(id,semester)
as 
select id,semester from courses where subject in ( select id from subjects where code = 'COMP9024');
;

create or replace view test7(student,semester)
as 
select course_enrolments.student,test5.semester from course_enrolments,test5 where course_enrolments.course = test5.id and grade = 'HD' and student in ( select id from students where stype='intl');
;

create or replace view test8(student,semester)
as
select course_enrolments.student,test6.semester from course_enrolments,test6 where course_enrolments.course = test6.id and grade = 'HD' and student in ( select id from students where stype='intl'); 
;

create or replace view Q3(unswid, name)
as 
--... SQL statements, possibly using other views/functions defined by you ...
select Test7.student from Test7,Test8 where Test7.student = Test8.student and Test7.semester = Test8.semester;
;

-- Q4:

create or replace view test9(student,HD_count)
as 
select student, count(student) as HD_count from course_enrolments where grade = 'HD' group by student;
;

create or replace view Q4(num_student)
as
--... SQL statements, possibly using other views/functions defined by you ...
select count(*) from test9 where hd_count> (  (select count(*) from course_enrolments where grade ='HD') where mark is not null / (select count(distinct student) from course_enrolments) where mark is not null ) ;
;

--Q5:
create or replace view test10(course,max)
as 
select course,max(mark) from course_enrolments where mark is not null group by course having count(mark is not null)>=20;
;

create or replace view test12 (semester,min_max)
as 
select semester,min(max) from test10,test11 where test10.course = test11.id group by semester;
;

create or replace view test13 
as 
select test10.course,test10.max,test11.subject,test11.semester from test10,test11 where test10.course = test11.id;
;

create or replace view test14(sem,sub)
as 
select test13.semester,test13.subject::integer from test13,test12 where test13.semester = test12.semester and test13.max = test12.min_max;
;

create or replace view Q5(code, name, semester)
as
--... SQL statements, possibly using other views/functions defined by you ...
select subjects.code,subjects.name,semesters.name as semester from subjects,test14,semesters where subjects.id = test14.sub and semesters.id=test14.sem;
;

-- Q6:

create or replace view t15 
as 
select distinct id from students where id in (select student from program_enrolments where id in (select partof from stream_enrolments where stream in (select id from streams where name = 'Management')) and semester = ( select id from semesters where term = 'S1' and year = '2010')) and stype='local';
;

create or replace view t16 
as 
select distinct student from course_enrolments where course in (select id from courses where subject in (select id from subjects where offeredby = (select id from orgunits where name = 'Faculty of Engineering')) ;
;

create or replace view Q6(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
select count(id) from t15 where id not in ( select id from t16)
;

-- Q7:

create or replace view test17(course,mark)
as 
select course,mark from course_enrolments where course in ( select id from courses where subject in (select id from subjects where name ='Database Systems' )) and mark is not null;
;

create or replace view test18(semester,avg)
as
select semester,avg(mark)::numeric(4,2) from test17,courses where test17.course = courses.id group by semester; 
;

create or replace view Q7(year, term, average_mark)
as
--... SQL statements, possibly using other views/functions defined by you ...
select semesters.year,semesters.term,test18.avg from semesters,test18 where test18.semester = semesters.id;
;

-- Q8: 

create or replace view test19
as 
select id year,term from semesters where year between 2004 and 2013 and (term = 'S1' or term ='S2');
;

create or replace view test20
as 
select id, name, code from subjects where code like 'COMP93%' and id in ( select subject from courses where semester in (select id from test19) group by subject having count(subject)>=20);
;

create or replace view test21(id,subject)
as 
select id,subject from courses where subject in ( select id from test20 ) ;
;

create or replace view test22(student,course)
as 
select student,course from course_enrolments,test21 where test21.id = course_enrolments.course and mark is not null and mark < 50;
;

create or replace view test23(student,subject)
as 
select test22.student,test21.subject from test22,test21 where test22.course = test21.id;
;

create or replace view test24(student)
as 
SELECT distinct student FROM test23 as t23 WHERE NOT EXISTS ( (SELECT t20.id FROM test20 as t20 ) EXCEPT (SELECT tes.subject FROM  test23 as tes WHERE tes.student = t23.student ) );
;


create or replace view Q8(zid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select concat('z', cast (people.unswid  as varchar)), people.name from people,test24 where test24.student = people.id;
;

-- Q9:

create or replace view test26(student,semester,program)
as 
select student,semester,program from program_enrolments where program in (select program from program_degrees where abbrev = 'BSc' );
;

create or replace view test33(student,course,mark)
as 
select student,course,mark from course_enrolments where student in (select student from test26);
;

create or replace view test34(student,course,mark,semester)
as 
select student,course,mark,semester from test33,courses where test33.course = courses.id;
;

create or replace view test35(student,semester,program,course,mark)
as 
select test26.student,test26.semester,test26.program,test34.course,test34.mark from test26 , test34 where test26.student=test34.student and test26.semester = test34.semester;
;


create or replace view test36
as 
select test35.student,test35.semester,test35.program,test35.course,test35.mark from test35,semesters where test35.semester = semesters.id and semesters.term='S2' and semesters.year='2010';
;

create or replace view test37(student,course)
as 
select student,course from test36 group by program,student,course having count(mark>=50)>=1;
;


create or replace view test38(student,program,course,mark)
as 
select test36.student,test36.program,test36.course,test36.mark from test36,test37 where test36.student = test37.student and test36.course = test37.course;
;


create or replace view test40 
as
select * from test35 where mark>=50; 
;

create or replace view test44
as 
select * from test40 where semester in (select id from semesters where year < 2011) ;
;

create or replace view test45 
as
select student,program,avg(mark) from test44 group by student,program having avg(mark)>=80 ;
;

create or replace view test46
as
select test44.student,test44.semester,test44.program,test44.course,test44.mark,subjects.uoc from test44,courses,subjects where test44.course = courses.id and courses.subject = subjects.id; 
;


create or replace view test42
as 
select student,program,sum(uoc)as UOC from test46 group by program,student;
;


create or replace view test47
as 
select test42.student,test42.program,test42.uoc,test43.uoc as min_uoc from test42,test43 where test42.program = test43.id;
;

create or replace view test48
as 
select * from test47 where test47.uoc>=test47.min_uoc;
;

create or replace view Q9(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select unswid, name from people where id in (select distinct test45.student from test45,test48,test38 where test45.student =test38.student and test38.student= test48.student) ;
;

-- Q10:


create or replace view test49(id,unswid,rtype,longname) 
as 
select id, unswid,rtype,longname from rooms where rtype in (select id from room_types where description = 'Lecture Theatre');
;

create or replace view test50(id,course,room)
as 
select id,course,room from classes where room in ( select  id from test49);
;

create or replace view test51
as 
select * from test50 where course in (select id from courses where id in ( select course from test50) and semester in (select id from semesters where year =2011 and term='S1')) ;
;

create or replace view test52(room,count)
as 
select room,count(id) from test51 group by room;
;

create or replace view test53 
as 
select id, unswid, longname,coalesce(count,0) as num from test49 LEFT outer join test52 on test49.id = test52.room order by num desc;
;


create or replace view Q10(unswid, longname, num, rank)
as
--... SQL statements, possibly using other views/functions defined by you ...
select unswid,longname,num, rank()over (order by num desc) from test53;
;
