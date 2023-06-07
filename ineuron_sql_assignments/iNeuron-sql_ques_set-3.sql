-- Q 101
CREATE TABLE user_activity
(
  username VARCHAR(25),
  activity VARCHAR(25),
  start_date DATE,
  end_date DATE
);

INSERT INTO user_activity VALUES('Alice', 'Travel', '2020-02-12', '2020-02-20');
INSERT INTO user_activity VALUES('Alice', 'Dancing', '2020-02-21', '2020-02-23');
INSERT INTO user_activity VALUES('Alice', 'Travel', '2020-02-24', '2020-02-28');
INSERT INTO user_activity VALUES('Bob', 'Travel', '2020-02-11', '2020-02-18');

select * from user_activity;

with cte as(
select username,activity,start_date,end_date,
dense_rank() over(partition by username order by start_date) as rnk,
count(*) over(partition by username) as total_cnt
from user_activity)

select username,activity,start_date,end_date
from cte
where
case 
	when total_cnt=1 
then 1
	when rnk = 2 
then 1
end;

-- Q 102 SAME AS 101

-- Q 103
CREATE TABLE students_tbl(
		id INT,
		name VARCHAR(20),
		marks INT
	);


INSERT INTO students_tbl VALUES
		(1,'ASHLEY',81),
		(2,'SAMANTHA',75),
		(3,'JULIA',76),
		(4,'BELVET',84);

select * from students_tbl;

select name from students_tbl
where marks > 75
order by right(name,3),id;

-- 	Q 104