-- Q 53
CREATE TABLE customers
(
  id INT,
  name VARCHAR(25),
  CONSTRAINT pk_customers PRIMARY KEY (id)
);

CREATE TABLE orders
(
  id INT,
  customer_id INT,
  CONSTRAINT pk_orders PRIMARY KEY (id),
  CONSTRAINT fk_customer_order FOREIGN KEY(customer_id)
    REFERENCES customers(id)
);

INSERT INTO customers VALUES(1, 'Joe');
INSERT INTO customers VALUES(2, 'Henry');
INSERT INTO customers VALUES(3, 'Sam');
INSERT INTO customers VALUES(4, 'Max');

INSERT INTO orders VALUES(1, 3);
INSERT INTO orders VALUES(2, 1);

select * from customers;
select * from orders;

select c.name
from orders o right join customers c on o.customer_id = c.id
where o.customer_id is null;


-- Q54
CREATE TABLE employee(
        employee_id INT,
        team_id INT,
        CONSTRAINT prime_key PRIMARY KEY(employee_id)
    );


INSERT INTO employee VALUES 
        (1,8),
        (2,8),
        (3,8),
        (4,7),
        (5,9),
        (6,9);
        
select * from employee;

select * from(
select employee_id,
		count(employee_id) over(partition by team_id) as team_size
from employee) tmp order by team_size desc;

-- 2nd method
SELECT 
        employee_id,
        COUNT(employee_id) OVER(PARTITION BY team_id ORDER BY employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS team_size
FROM 
        employee
ORDER BY 
        employee_id;

-- Q55
CREATE TABLE person(
        id INT,
        name VARCHAR(20),
        phone_number VARCHAR(20),
        CONSTRAINT prime_key PRIMARY KEY(id)
    );


CREATE TABLE country(
        name VARCHAR(20),
        country_code VARCHAR(20),
        CONSTRAINT prime_key PRIMARY KEY(country_code)
    );


CREATE TABLE calls(
        caller_id INT,
        callee_id INT,
        duration INT
    );


INSERT INTO person VALUES 
        (3,'JONATHON','051-1234567'),
        (21,'ELVIS','051-7654321'),
        (1,'MONCEF','212-1234567'),
        (2,'MAROUA','212-6523651'),
        (7,'MEIR','972-1234567'),
        (9,'RACHEL','972-0011100');


INSERT INTO calls VALUES 
        (1,9,33),
        (1,2,59),
        (3,12,102),
        (3,12,330),
        (12,3,5),
        (7,9,13),
        (7,1,3),
        (9,7,1),
        (1,7,7),
        (2,9,4);


INSERT INTO country VALUES 
        ('PERU','51'),
        ('ISRAEL','972'),
        ('MOROCCO','212'),
        ('GERMANY','49'),
        ('ETHIOPIA','251');
        
select * from person;
select * from country;
select * from calls;

with caller_receiver_tbl as(
				select caller_id as caller_receiver_id,
						duration
				from calls
                UNION all
                select callee_id as caller_receiver_id,
						duration
				from calls
),
calls_duration_avg as (
				select distinct(cn.name),
						avg(c.duration) over() as global_avg,
                        avg(c.duration) over(partition by cn.name) as country_avg
				from person p
                join country cn on cast(substring_index(p.phone_number, '-',1)as unsigned) = cast(cn.country_code as unsigned)
                join caller_receiver_tbl c on p.id = c.caller_receiver_id)

select name as country
from calls_duration_avg
where country_avg > global_avg;


-- Q56
CREATE TABLE activity(
        player_id INT,
        device_id INT,
        event_date DATE,
        games_played INT,
        CONSTRAINT prime_key PRIMARY KEY(player_id, event_date)
	);


INSERT INTO activity VALUES 
        (1,2,'2016-03-01',5),
        (1,2,'2016-03-02',6),
        (2,3,'2017-06-25',1),
        (3,1,'2016-03-02',0),
        (3,4,'2018-07-03',5);

select * from activity;

with cte as(
select player_id,
		device_id,
        dense_rank() over(partition by player_id order by event_date) as rnk
from activity)

select player_id, device_id
from cte where rnk=1;

-- Q57
CREATE TABLE order_tb(
        order_number INT,
        customer_number INT,
        CONSTRAINT prime_key PRIMARY KEY(order_number)
    );


INSERT INTO order_tb VALUES
        (1,1),
        (2,2),
        (3,3),
        (4,3);



WITH temp_orders AS (
			SELECT 
				DISTINCT customer_number, 
				DENSE_RANK() OVER(ORDER BY total_orders DESC) AS ranking
			FROM ( 
				SELECT  
        				customer_number, 
					COUNT(order_number) OVER(PARTITION BY customer_number) total_orders
				FROM 
					order_tb
			)   temp_cust_details
		)

SELECT  
	customer_number
FROM 
        temp_orders
WHERE 
        ranking = 1;
        

-- Q58
CREATE TABLE cinema(
        seat_id INT AUTO_INCREMENT,
        free BOOLEAN,
        CONSTRAINT prime_key PRIMARY KEY(seat_id)
    );


INSERT INTO cinema (free) VALUES 
        (1),(0),(1),(1),(1),(1),(0),(1),
        (1),(0),(1),(1),(1),(0),(1),(1);
        
select * from cinema;

with seatid_with_diff_with_next_val as(
							select seat_id,
                                seat_id - lead(seat_id,1) over(order by seat_id) as diff_next,
                                seat_id - lag(seat_id,1) over(order by seat_id) as diff_prev
							from cinema
                            where free <> 0)
select seat_id
from seatid_with_diff_with_next_val
where diff_next=-1 or diff_prev = 1;


-- Q59
CREATE TABLE sales_person(
        sales_id INT,
        name VARCHAR(20),
        salary INT,
        commission_rate INT,
        hire_date VARCHAR(25),
        CONSTRAINT prime_key PRIMARY KEY(sales_id)
    );


INSERT INTO sales_person VALUES
        (1,'JOHN',100000,6,'4/1/2006'),
        (2,'AMY',12000,5,'5/1/2010'),
        (3,'MARK',65000,12,'12/25/2008'),
        (4,'PAM',25000,25,'1/1/2005'),
        (5,'ALEX',5000,10,'2/3/2007');


CREATE TABLE company(
        company_id INT,
        name VARCHAR(20),
        city VARCHAR(10),
        CONSTRAINT prime_key PRIMARY KEY(company_id)
    );


INSERT INTO company VALUES
        (1,'RED','BOSTON'),
        (2,'ORANGE','NEW YORK'),
        (3,'YELLOW','BOSTON'),
        (4,'GREEN','AUSTIN');


CREATE TABLE orders_tbl(
        order_id INT,
        order_date VARCHAR(30),
        company_id INT,
        sales_id INT,
        amount INT,
        CONSTRAINT prime_key PRIMARY KEY(order_id),
        CONSTRAINT company_foreign_key FOREIGN KEY (company_id) REFERENCES company(company_id),
        CONSTRAINT sales_foreign_key FOREIGN KEY (sales_id) REFERENCES sales_person(sales_id)
    );


INSERT INTO orders_tbl VALUES
        (1,'1/1/2014',3,4,10000),
        (2,'2/1/2014',4,5,5000),
        (3,'3/1/2014',1,1,50000),
        (4,'4/1/2014',1,4,25000);
        
select * from orders_tbl;

-- APPROACH 1
select name
from sales_person 
where sales_id not in(select o.sales_id from orders_tbl o inner join company c on o.company_id = c.company_id
						where c.name = 'RED');
                        
-- APPROACH 2
select s.name
from sales_person s
where not exists (select * from orders_tbl o join company c on o.company_id = c.company_id
					where s.sales_id = o.sales_id and c.name = 'RED');
                    
-- Q 60
CREATE TABLE triangle(
        x INT,
        y INT,
        z INT,
        CONSTRAINT prime_key PRIMARY KEY(x,y,z)
    );


INSERT INTO triangle VALUES
        (13,15,30),
        (10,20,15);
        
select * from triangle;

select x,y,z,
(case when x+y >z and
	 y+z > x and 
     x+z > y then 'Yes'
	else 'No' end) as tri
    from triangle;
    
-- Q61
create table point(
	x int,
    constraint prime_key primary key(x)
    );
    
INSERT INTO point VALUES
        (-1),
        (0),
        (2);
        
select * from point;

select min(abs(p.x - p1.x)) as shortest
from point p inner join point p1 
where p.x != p1.x;

-- Q62
CREATE TABLE actor_director(
        actor_id INT,
        director_id INT,
        timestamp INT,
        CONSTRAINT prime_key PRIMARY KEY(timestamp)
    );


INSERT INTO actor_director VALUES 
        (1,1,0),
        (1,1,1),
        (1,1,2),
        (1,2,3),
        (1,2,4),
        (2,1,5),
        (2,1,6);
        
select * from actor_director;

select actor_id, director_id
from actor_director
group by actor_id, director_id
having count(*) >= 3;


-- Q63
CREATE TABLE sales(
        sale_id INT,
        product_id INT,
        year INT,
        Quantity INT,
        price INT,
        CONSTRAINT prime_key PRIMARY KEY(sale_id, year)
    );


CREATE TABLE product(
        product_id INT,
        product_name VARCHAR(20),
        CONSTRAINT prime_key PRIMARY KEY(product_id)
    );


INSERT INTO sales VALUES 
        (1,100,2008,10,5000),
        (2,100,2009,12,5000),
        (7,200,2011,15,9000);


INSERT INTO product VALUES
        (100,'NOKIA'),
        (200,'APPLE'),
        (300,'SAMSUNG');
        
select * from sales;
select * from product;

select p.product_name, s.year, s.price
from sales s join product p on s.product_id = p.product_id;

-- Q64
CREATE TABLE project(
        project_id INT,
        employee_id INT,
        CONSTRAINT prime_key PRIMARY KEY(project_id, employee_id)
    );


INSERT INTO project VALUES 
        (1,1),
        (1,2),
        (1,3),
        (2,1),
        (2,4);


CREATE TABLE employee_tbl(
        employee_id INT,
        name VARCHAR(20),
        experience_years INT,
        CONSTRAINT prime_key PRIMARY KEY(employee_id)
    );


INSERT INTO employee_tbl VALUES 
        (1,'KHALED',3),
        (2,'ALI',2),
        (3,'JOHN',1),
        (4,'DOE',2);
        
select * from employee_tbl;

select distinct p.project_id,
round(avg(e.experience_years) over(partition by p.project_id),2) as average_years
from project p join employee_tbl e on p.employee_id = e.employee_id;

-- Q65
CREATE TABLE product_tb(
        product_id INT,
        product_name VARCHAR(20),
        unit_price INT,
        CONSTRAINT prime_key PRIMARY KEY(product_id)
    );


INSERT INTO product_tb VALUES 
        (1,'S8',1000),
        (2,'G4',800),
        (3,'Iphone',1400);


CREATE TABLE sales_tb(
        seller_id INT,
        product_id INT,
        buyer_id INT,
        sale_date DATE,
        quantity INT,
        price INT,
        CONSTRAINT FOREIGN_KEY FOREIGN KEY(product_id) REFERENCES product_tb(product_id)
    );


INSERT INTO sales_tb VALUES 
        (1,1,1,'2019-01-21',2,2000),
        (1,2,2,'2019-01-21',1,800),
        (2,2,3,'2019-01-21',1,800),
        (3,3,4,'2019-01-21',2,2800);
        
select * from sales_tb;
select * from product_tb;

with cte as (select distinct seller_id,
				sum(price) over(partition by seller_id) as price
                from sales_tb),
cte2 as (select seller_id,
rank() over(order by price desc) as rnk
from cte)

select seller_id from cte2
where rnk=1;

-- Q66
select * from sales_tb;
select * from product_tb;

select s.buyer_id
from product_tb p inner join sales_tb s on p.product_id = s.product_id
where p.product_name IN('S8')
and p.product_name not in('Iphone');


-- Q67
CREATE TABLE customer(
	customer_id INT,
	name VARCHAR(20),
	visited_on DATE,
	amount INT,
	CONSTRAINT PRIMARY_KEY PRIMARY KEY(customer_id,visited_on)
	);


INSERT INTO customer VALUES 
	(1,'JOHN','2019-01-01',100),
	(2,'DANIEL','2019-01-02',110),
	(3,'JADE','2019-01-03',120),
	(4,'KHALED','2019-01-04',130),
	(5,'WINSTON','2019-01-05',110),
	(6,'ELVIS','2019-01-06',140),
	(7,'ANNA','2019-01-07',150),
	(8,'MARIA','2019-01-08',80),
	(9,'JAZE','2019-01-09',110),
	(1,'JOHN','2019-01-10',130),
	(3,'JADE','2019-01-10',150);


select * from customer;


with tmp as (select visited_on, sum(amount) as amount
				from customer group by visited_on),
	 tmp_cust as (select visited_on,
					sum(amount) over(order by visited_on rows between 6 preceding and current row) as weekly_amount,
                    round(avg(amount) over(order by visited_on rows between 6 preceding and current row),2) as average_amount,
                    dense_rank() over(order by visited_on) as rnk
                    from tmp)
select visited_on, weekly_amount, average_amount
from tmp_cust
where rnk > 6;     

-- Q68
CREATE TABLE scores(
        player_name VARCHAR(20),
        gender VARCHAR(20),
        day DATE,
        score_points INT,
        CONSTRAINT prime_key PRIMARY KEY(gender,day)
    );


INSERT INTO scores VALUES
        ('ARON','F','2020-01-01',17),
        ('ALICE','F','2020-01-07',23),
        ('BAJRANG','M','2020-01-07',7),
        ('KHALI','M','2019-12-25',11),
        ('SLAMAN','M','2019-12-30',13),
        ('JOE','M','2019-12-31',3),
        ('JOSE','M','2019-12-18',2),
        ('PRIYA','F','2019-12-31',23),
        ('PRIYANKA','F','2019-12-30',17);       
        
select * from scores;

select gender, day,
sum(score_points) over(partition by gender order by day rows between unbounded preceding and current row) as total_points
from scores;

-- APPROACH 2
SELECT
  gender,
  day,
  sum(score_points) OVER(PARTITION BY gender ORDER BY day) AS total
FROM
  scores;
  
-- 69
CREATE TABLE logs
(
  log_id INT,
  CONSTRAINT pk_logs PRIMARY KEY (log_id)
);

INSERT INTO logs VALUES(1),(2),(3),(7),(8),(10);
select * from logs;
    
with cte as(SELECT 
					log_id,
					ROW_number() OVER(ORDER BY log_id) AS RN
				FROM 
					logs),
	tmp_log as	(SELECT 
                        log_id, 
                        DENSE_RANK() OVER(ORDER BY log_id - RN) AS rnk
                FROM cte)
select min(log_id) as start_id,
max(log_id) as end_id
from tmp_log
group by rnk;

-- Q70
CREATE TABLE students(
        student_id INT,
        student_name VARCHAR(20),
        CONSTRAINT prime_key PRIMARY KEY(student_id)
    );


CREATE TABLE subjects(
        subject_name VARCHAR(20),
        CONSTRAINT prime_key PRIMARY KEY(subject_name)
    );

CREATE TABLE exams(
        student_id INT,
        subject_name VARCHAR(20)
    );


INSERT INTO students VALUES
        (1,'ALICE'),
        (2,'BOB'),
        (13,'JOHN'),
        (6,'ALEX');


INSERT INTO subjects VALUES
        ('MATHS'),
        ('PHYSICS'),
        ('PROGRAMMING');


INSERT INTO exams VALUES    
        (1,'MATHS'),
        (1,'PHYSICS'),
        (1,'PROGRAMMING'),
        (2,'PROGRAMMING'),
        (1,'PHYSICS'),
        (1,'MATHS'),
        (13,'MATHS'),
        (13,'PROGRAMMING'),
        (13,'PHYSICS'),
        (2,'MATHS'),
        (1,'MATHS');
        
select st.student_id,st.student_name,s.subject_name,
		sum(case when e.subject_name is not null then 1
				else 0 end) as attended_exams
		from exams e join subjects s on e.subject_name = s.subject_name
        right join students st on st.student_id = e.student_id
        group by  st.student_id, st.student_name, s.subject_name
        order by st.student_id, st.student_name;
        
        
-- Q71
CREATE TABLE employees(
        employee_id INT,
        employee_name VARCHAR(20),
        manager_id INT,
        CONSTRAINT prime_key PRIMARY KEY(employee_id)
    );


INSERT INTO employees VALUES    
        (1,'BOSS',1),
        (3,'ALICE',3),
        (2,'BOB',1),
        (4,'DANIEL',2),
        (7,'LUIS',4),
        (8,'JHON',3),
        (9,'ANGELA',8),
        (77,'ROBERT',1);
        
select * from employees;

with recursive emp_hir as (select employee_id,
							  manager_id,
							  employee_name,
                              1 as lvl
						from employees
                        where employee_name = 'BOSS'
                        union
                        select e.employee_id,
							  e.manager_id,
							  e.employee_name,
                              eh.lvl +1 as lvl
						from emp_hir eh
                        join employees e on eh.employee_id = e.manager_id
                        where e.employee_name <> 'BOSS')
                        
select employee_id 
from emp_hir 
where employee_name <> 'BOSS';


-- Q72
CREATE TABLE transactions(
        id INT,
        country VARCHAR(20),
        state ENUM ('APPROVED','DECLINED'),
        amount INT,
        trans_date DATE,
        CONSTRAINT prime_key PRIMARY KEY(id)
    );


INSERT INTO transactions VALUES 
        (121,'US','APPROVED',1000,'2018-12-18'),
        (122,'US','DECLINED',2000,'2018-12-19'),
        (123,'US','APPROVED',2000,'2019-01-01'),
        (124,'DE','APPROVED',2000,'2019-01-07');
        
select * from transactions;

select 
					date_format(trans_date, '%Y-%M') as month,country,
                    count(id) as trans_count,
                    count(case when state='APPROVED' then 1 end) as approved_count,
                    sum(amount) as trans_total_amount,
                    sum(case when state='APPROVED' then amount end) as approved_total_amount
                    from transactions
                    group by date_format(trans_date, '%Y-%M') , country;
                    
                    
-- Q73
CREATE TABLE actions(
        user_id INT,
        post_id INT,
        action_date DATE,
        action ENUM ('VIEW','LIKE','REACTION','COMMENT','REPORT','SHARE'),
        extra VARCHAR(20)
    );


CREATE TABLE removals(
        post_id INT,
        remove_date DATE,
        CONSTRAINT prime_key PRIMARY KEY(post_id)
    );


INSERT INTO actions VALUES
        (1,1,'2019-07-01','VIEW','NULL'),
        (1,1,'2019-07-01','LIKE','NULL'),
        (1,1,'2019-07-01','SHARE','NULL'),
        (2,2,'2019-07-04','VIEW','NULL'),
        (2,2,'2019-07-04','REPORT','SPAM'),
        (3,4,'2019-07-04','VIEW','NULL'),
        (3,4,'2019-07-04','REPORT','SPAM'),
        (4,3,'2019-07-02','VIEW','NULL'),
        (4,3,'2019-07-02','REPORT','SPAM'),
        (5,2,'2019-07-03','VIEW','NULL'),
        (5,2,'2019-07-03','REPORT','RACISM'),
        (5,5,'2019-07-03','VIEW','NULL'),
        (5,5,'2019-07-03','REPORT','RACISM');


INSERT INTO removals VALUES
        (2,'2019-07-20'),
        (3,'2019-07-18');

select * from actions;
select * from removals;

with tmp_action as (select action_date, post_id, count(extra) over(partition by action_date) as num_post_reported_spam
					from actions where extra = 'SPAM'),
	 avg_pct as (select round(count(post_id)/num_post_reported_spam * 100,2) as pct from tmp_action
					where post_id IN(select post_id from removals) group by action_date)

select round(avg(pct),2) as average_daily_percent from avg_pct;

-- 74 & 75 same as Q.43 
-- Q76

CREATE TABLE salaries(
        company_id INT,
        employee_id INT,
        employee_name VARCHAR(20),
        salary INT,
        CONSTRAINT prime_key PRIMARY KEY(company_id, employee_id)
    );


INSERT INTO salaries VALUES    
        (1,1,'TONY',2000),
        (1,2,'PRONUB',21300),
        (1,3,'TYRROX',10800),
        (2,1,'PAM',300),
        (2,7,'BASSEM',450),
        (2,9,'HERMIONE',700),
        (3,7,'BOCABEN',100),
        (3,2,'OGNJEN',2200),
        (3,13,'NYAN CAT',3300),
        (3,15,'MORNING CAT',7777);
        
select * from salaries;

with max_salary_by_company as(select company_id, employee_id, employee_name,salary, max(salary) over(partition by company_id) as max_salary from salaries)
select company_id, employee_id, employee_name,
round(case when max_salary > 10000 then salary - salary * 0.49
when max_salary between 1000 and 10000 then salary - salary * 0.24
else max_salary END, 0) as salary
from max_salary_by_company;

-- Q77

CREATE TABLE variables(
        name VARCHAR(2),
        value INT,
        CONSTRAINT prime_key PRIMARY KEY(name)
    );


INSERT INTO variables VALUES    
        ('x',66),
        ('y',77);
       
       
CREATE TABLE expressions(
        left_operand VARCHAR(2),
        operator ENUM('<','=','>'),
        right_operand VARCHAR(2),
        CONSTRAINT prime_key PRIMARY KEY(left_operand, operator, right_operand)
    );


INSERT INTO expressions VALUES    
        ('x','>','y'),
        ('x','<','y'),
        ('x','=','y'),
        ('y','>','x'),
        ('y','<','x'),
        ('x','=','x');
        
select * from expressions;

select e.left_operand, e.operator, e.right_operand,
(case when e.operator = '<' then if(l.value < r.value, 'True', 'False')
when e.operator = '>' then if(l.value > r.value, 'True', 'False')
						else if(l.value = r.value, 'True', 'False')
end) as result
from expressions e join variables l on 	e.left_operand = l.name
join variables r on e.right_operand = r.name;

-- Q78 same as Q55
-- Q79
CREATE TABLE employee_tb(
        employee_id INT,
        name VARCHAR(20),
        months INT,
        salary INT
    );


INSERT INTO employee_tb VALUES
        (12228,'ROSE',15,1968),
        (33645,'ANGELA',1,3443),
        (45692,'FRANK',17,1608),
        (56118,'PATRIK',7,1345),
        (74197,'KINBERLY',16,4372),
        (78454,'BONNIE',8,1771),
        (83565,'MICHAEL',6,2017),
        (98607,'TODD',5,3396),
        (99989,'JOE',9,3573);

select * from employee_tb;

select name from employee_tb order by name;

-- Q80
CREATE TABLE user_transactions
(
  transaction_id INT,
  product_id INT,
  spend DECIMAL(10,2),
  transaction_date DATE
);


INSERT INTO user_transactions VALUES(1341, 123424, 1500.60, '2019-12-31');
INSERT INTO user_transactions VALUES(1423, 123424, 1000.20, '2020-12-31');
INSERT INTO user_transactions VALUES(1623, 123424, 1246.44, '2021-12-31');
INSERT INTO user_transactions VALUES(1322, 123424, 2145.32, '2022-12-31');

select * from user_transactions;

select date_format(transaction_date, '%Y') as year,
product_id, spend as curr_year_spend,
IFNULL(lag(spend) over(order by date_format(transaction_date, '%Y')),0) as prev_year_spend,
ifnull(ROUND(spend- Lag(spend) over(order by date_format(transaction_date, '%Y')) * 100.00/ Lag(spend) over(order by date_format(transaction_date, '%Y')),2),0) AS yoy_rate
from user_transactions
order by year;


-- Q81
CREATE TABLE inventory(
        item_id INT,
        item_type VARCHAR(20),
        item_category VARCHAR(20),
        square_foot FLOAT
    );


INSERT INTO inventory VALUES
        (1374,'PRIME_ELIGIBLE','MINI FRidGE',68.00),
        (4245,'NOT_PRIME','STANDING LAMP',26.40),
        (2452,'PRIME_ELIGIBLE','TELEVISION',85.00),
        (3255,'NOT_PRIME','SidE TABLE',22.60),
        (1672,'PRIME_ELIGIBLE','LAPTOP',8.50);	
		
select * from inventory;
WITH product_inventory_summary AS
(
  SELECT
    item_type,
    SUM(square_foot) as square_footage_required,
    COUNT(item_id) as unique_item_count,
    500000 as total_space,
    FLOOR(500000/sum(square_foot))*sum(square_foot) as space_used,
    FLOOR(500000/sum(square_foot))*COUNT(item_id) as item_count
  FROM 
    inventory
  GROUP BY 
    item_type
)
SELECT 
  t1.item_type,
  CASE
    WHEN t1.item_type = 'prime_eligible'
      THEN t1.item_count
    ELSE
      FLOOR((500000-t2.space_used)/t1.square_footage_required)*t1.unique_item_count
  END AS item_count
FROM
  product_inventory_summary t1
  JOIN product_inventory_summary t2 ON t1.item_type <> t2.item_type
ORDER BY t1.item_type DESC
;

-- Q82

CREATE TABLE user_actions(
        user_id INT,
        event_id INT,
        event_type ENUM('SIGN-IN','LIKE','COMMENT'),
        event_date DATETIME
    );


INSERT INTO user_actions VALUES
        (445,7765,'SIGN-IN','2022-05-31 12:00:00'),
        (742,6458,'SIGN-IN','2022-06-03 12:00:00'),
        (445,3634,'LIKE','2022-06-05 12:00:00'),
        (742,1374,'COMMENT','2022-06-05 12:00:00'),
        (648,3124,'LIKE','2022-06-18 12:00:00');

select * from user_actions;

select month(event_date) as month,
count(distinct user_id) as monthly_active_users
from user_actions u1
where event_date >= '2022-05-01' and event_date < '2022-07-01'
and exists(
select 1 from user_actions u2
where u1.user_id = u2.user_id
and month(u2.event_date) = month(u1.event_date)-1
and year(u2.event_date) = year(u1.event_date)
)
group by month(event_date);

-- Q83

CREATE TABLE search_frequency(
        searches INT,
        num_users INT
    );


INSERT INTO search_frequency VALUES
        (1,2),
        (2,2),
        (3,3),
        (4,1);
        
select * from search_frequency;



WITH bound AS(
SELECT *,
  SUM(num_users) OVER(ORDER BY searches) - num_users as lower_bound,
  SUM(num_users) OVER(ORDER BY searches) as upper_bound,
  SUM(num_users) OVER()/2 as mid
FROM search_frequency)

SELECT
  ROUND(sum(searches)*1.0/count(1),1)
FROM bound
WHERE mid BETWEEN lower_bound AND upper_bound;

select 
  round(1.0*sum(searches)/count(*),1) as median
from rnk
where abs(cnt-mid)<=0.5;

-- Q84
CREATE TABLE advertiser(
        user_id VARCHAR(20),
        status ENUM('NEW','EXISTING','CHURN','RESURRECT')
    );


CREATE TABLE daily_pay(
        user_id VARCHAR(20),
        paid DECIMAL
    );


INSERT INTO advertiser VALUES
        ('BING','NEW'),
        ('YAHOO','NEW'),
        ('ALIBABA','EXISTING');


INSERT INTO daily_pay VALUES
        ('YAHOO',45.00),
        ('ALIBABA',100.00),
        ('TARGET',13.00);


with cte as(
select a.user_id, a.status, d.paid
from advertiser a
left join daily_pay d
on a.user_id = d.user_id
UNION
select d.user_id, a.status, d.paid
from daily_pay d
left join advertiser a
on d.user_id = a.user_id)

select user_id,
CASE WHEN paid is NULL THEN 'CHURN'
    when status is NULL and paid IS NOT NULL THEN 'NEW'
    when status != 'CHURN' and paid IS NOT NULL THEN 'EXISTING'
    when status = 'CHURN' and paid IS NOT NULL THEN 'RESURRECT'
    end as new_status
from cte
ORDER BY user_id;

-- Q85
CREATE TABLE server_utilization(
        server_id INT,
        session_status VARCHAR(20),
        status_time VARCHAR(25)
    );


INSERT INTO server_utilization VALUES
        (1,'start','08/02/2022 10:00:00'),
        (1,'stop','08/04/2022 10:00:00'),
        (2,'stop','08/24/2022 10:00:00'),
        (2,'start','08/17/2022 10:00:00');
        
select * from server_utilization;        


-- Q86
CREATE TABLE transactions_tb
(
  transaction_id INT,
  merchant_id INT,
  credit_card_id INT,
  amount INT,
  transaction_timestamp TIMESTAMP
);

INSERT INTO transactions_tb VALUES(1, 101, 1, 100, '2022-09-25 12:00:00');
INSERT INTO transactions_tb VALUES(2, 101, 1, 100, '2022-09-25 12:08:00');
INSERT INTO transactions_tb VALUES(3, 101, 1, 100, '2022-09-25 12:28:00');
INSERT INTO transactions_tb VALUES(4, 102, 2, 300, '2022-09-25 12:00:00');
INSERT INTO transactions_tb VALUES(5, 102, 2, 400, '2022-09-25 14:00:00');

select * from transactions_tb;

with cte as(
select merchant_id, credit_card_id, amount,
count(*) over(partition by credit_card_id,amount order by transaction_timestamp
				range between interval '10' minute preceding and current row) as moving_count
from transactions_tb)

select count(*) as payment_count from cte where moving_count >1;


-- Q87
CREATE TABLE orders_tb(
        order_id INT,
        customer_id INT,
        trip_id INT,
        status ENUM('COMPLETED SUCCESSFULLY','COMPLETED INCORRECTLY','NEVER_RECEIVED'),
        order_timestamp VARCHAR(30)
    );


INSERT INTO orders_tb VALUES  
        (727424,8472,100463,'COMPLETED SUCCESSFULLY','06/05/2022 09:12:00'),
        (242513,2341,100482,'COMPLETED INCORRECTLY','06/05/2022 14:40:00'),
        (141367,1314,100362,'COMPLETED INCORRECTLY','06/07/2022 15:03:00'),
        (582193,5421,100657,'NEVER_RECEIVED','07/07/2022 15:22:00'),
        (253613,1314,100213,'COMPLETED SUCCESSFULLY','06/12/2022 13:43:00');


CREATE TABLE trips(
        dasher_id INT,
        trip_id INT,
        estimated_delivery_timestamp VARCHAR(25),
        actual_delivery_timestamp VARCHAR(25)
    );


INSERT INTO TRIPS VALUES 
        (101,100463,'06/05/2022 09:42:00','06/05/2022 09:38:00'),
        (102,100482,'06/05/2022 15:10:00','06/05/2022 15:46:00'),
        (101,100362,'06/07/2022 15:33:00','06/07/2022 16:45:00'),
        (102,100657,'07/07/2022 15:52:00',NULL),
        (103,100213,'06/12/2022 14:13:00','06/12/2022 14:10:00');


CREATE TABLE customers_tb(
        customer_id INT,
        signup_timestamp VARCHAR(30)
    );


INSERT INTO customers_tb VALUES    
        (8472,'05/30/2022 00:00:00'),
        (2341,'06/01/2022 00:00:00'),
        (1314,'06/03/2022 00:00:00'),
        (1435,'06/05/2022 00:00:00'),
        (5421,'06/07/2022 00:00:00');

select * from orders_tb;
select * from trips;
select * from customers_tb;

select round(sum(case when status != 'COMPLETED SUCCESSFULLY' then 1 else 0 end)*100.0/count(*),2) as bad_experience
from orders_tb o
join customers_tb c on
o.customer_id = c.customer_id
where o.order_timestamp < date_add(str_to_date(signup_timestamp,'%m/%d/%Y'), interval 14 day)
and month(str_to_date(signup_timestamp,'%m/%d/%Y')) = 06
and year(str_to_date(signup_timestamp,'%m/%d/%Y')) = 2022;

-- Q.88 SAME AS 68
-- Q.89 SAME AS 55

-- Q90
CREATE TABLE numbers(
        num INT,
        frequency INT
    );


INSERT INTO numbers VALUES  
        (0,7),
        (1,1),
        (2,3),
        (3,1);

select * from numbers;

with recursive rec_cte as(
					select num, frequency, 1 as cnt from numbers
                    union
                    select num, frequency, cnt+1 as cnt from rec_cte where cnt < frequency),

med_cte as (select num, frequency,cnt,
			row_number() over(order by num) row_num,
            count(*) over () total_num
            from rec_cte
            )
select round(avg(median),1) as median from(
select case when total_num % 2 = 0 then(
select avg(num) as median from med_cte where row_num between total_num/2 and total_num/2+1)
when total_num % 2 != 0 then (select avg(num) as median from med_cte where row_num = total_num/2)
end as median
from med_cte)t;



-- Q91


CREATE TABLE emp_tb
(
  employee_id INT,
  department_id INT,
  CONSTRAINT pk_employee PRIMARY KEY(employee_id)
);

CREATE TABLE salary
(
  id INT,
  employee_id INT,
  amount INT,
  pay_date DATE,
  CONSTRAINT pk_salary PRIMARY KEY(id),
  CONSTRAINT fk_employee FOREIGN KEY(employee_id)
    REFERENCES emp_tb(employee_id)
);

INSERT INTO emp_tb VALUES(1, 1);
INSERT INTO emp_tb VALUES(2, 2);
INSERT INTO emp_tb VALUES(3, 2);

INSERT INTO salary VALUES(1, 1, 9000, '2017-03-31');
INSERT INTO salary VALUES(2, 2, 6000, '2017-03-31');
INSERT INTO salary VALUES(3, 3, 10000, '2017-03-31');
INSERT INTO salary VALUES(4, 1, 7000, '2017-02-28');
INSERT INTO salary VALUES(5, 2, 6000, '2017-02-28');
INSERT INTO salary VALUES(6, 3, 8000, '2017-02-28');

select * from salary;
select * from emp_tb;
with cte as(select s.employee_id, e.department_id, s.amount, s.pay_date,
			avg(amount) over(partition by month(pay_date) order by month(pay_date),employee_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as comp_sal,
            avg(amount) over(partition by month(pay_date),department_id order by month(pay_date) ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as dept_sal
            from salary s join emp_tb e on s.employee_id = e.employee_id
            )
select distinct date_format(pay_date, '%Y-%m') as pay_month,
		department_id,
        case when comp_sal = dept_sal then 'same'
			when comp_sal < dept_sal then 'higher'
            else 'lower'
		end as comparison
from cte;


-- Q92
-- leetcode hard level- game analysis V
CREATE TABLE activity_tbl(
        player_id INT,
        device_id INT,
        event_date DATE,
        games_played INT,
        CONSTRAINT prime_key PRIMARY KEY(player_id, event_date)
    );


INSERT INTO activity_tbl VALUES 
        (1,2,'2016-03-01',5),
        (1,2,'2016-03-02',6),
        (2,3,'2017-06-25',1),
        (3,1,'2016-03-01',0),
        (3,4,'2018-07-03',5);

select * from activity_tbl;

select install_dt,count(*)  as installs, round(sum(retention)/count(*),1) as Day1_retention
from(       
select player_id, min(event_date) as install_dt,
case when date_add(min(event_date), interval 1 day) in (select event_date from activity_tbl a where a.player_id = a1.player_id) then 1 else 0 end as retention
from activity_tbl a1
group by player_id)t
group by install_dt;

-- game analysis III -leetcode question
select * from activity_tbl;
select player_id, event_date,
sum(games_played) over(partition by player_id rows between unbounded preceding and current row) as games_played_so_far  from activity_tbl;


-- Q.93 SAME AS 50

-- Q94

CREATE TABLE student(
        student_id INT,
        student_name VARCHAR(20),
        CONSTRAINT prime_key PRIMARY KEY(student_id)
    );


CREATE TABLE exam(
        exam_id INT,
        student_id INT,
        score INT,
        CONSTRAINT prime_key PRIMARY KEY(exam_id,student_id)
    );


INSERT INTO student VALUES 
        (1,'DANIEL'),
        (2,'JADE'),
        (3,'STELLA'),
        (4,'JONATHAN'),
        (5,'WILL');


INSERT INTO exam VALUES
        (10,1,70),
        (10,2,80),
        (10,3,90),
        (20,1,80),
        (30,1,70),
        (30,3,80),
        (30,4,90),
        (40,1,60),
        (40,2,70),
        (40,4,80);

select * from student;
select * from exam;

with cte as(
select s.student_id as student_id ,s.student_name as student_name,e.score as score,
min(score) over(partition by exam_id or score) as min_st,
max(score) over(partition by exam_id or score) as max_st
from student s
join exam e on s.student_id = e.student_id),

student_highest_lowest AS(
  SELECT
    DISTINCT student_id
  FROM
    cte
  WHERE 
    score = min_st
    OR score = max_st
)

select student_id, student_name from student st where exists(select * from exam ex where ex.student_id = st.student_id) and st.student_id not in (select student_id from student_highest_lowest);


-- Q95 same as Q94

-- Q96
CREATE TABLE songs_history(
	history_id INT,
	user_id INT,
	song_id INT,
	song_plays INT
	);


INSERT INTO songs_history VALUES
	(10011,777,1238,11),
	(12452,695,4520,1);


CREATE TABLE songs_weekly(
	user_id INT,
	song_id INT,
	listen_time VARCHAR(25)
	);


INSERT INTO songs_weekly VALUES
        (777,1238,'08/01/2022 12:00:00'),
	(695,4520,'08/04/2022 08:00:00'),
	(125,9630,'08/04/2022 16:00:00'),
	(695,9852,'08/07/2022 12:00:00');

select * from songs_history;
select * from songs_weekly;

with streaming as(
select user_id, song_id, song_plays
from songs_history
union
select user_id, song_id, count(*) as song_plays
from songs_weekly
WHERE 
listen_time <= '08/04/2022 23:59:59'
group by user_id,song_id)
select user_id,song_id, sum(song_plays) as song_plays
from streaming
group by user_id,song_id;

-- Q97
CREATE TABLE emails(
	email_id INT,
	user_id INT,
	signup_date DATETIME
	);


INSERT INTO emails VALUES
	(125,7771,'2022-06-14 00:00:00'),
	(236,6950,'2022-07-01 00:00:00'),
	(433,1052,'2022-07-09 00:00:00');


CREATE TABLE texts(
	text_id INT,
	email_id INT,
	signup_action VARCHAR(20)
	);


INSERT INTO texts VALUES
	(6878,125,'CONFIRMED'),
	(6920,236,'NOT CONFIRMED'),
	(6994,236,'CONFIRMED');
    
select * from emails;
select * from texts;

with cte as(
select t.text_id as text_id,e.email_id as email_id,case when signup_action = 'CONFIRMED' then 1 end as confirmed_users
from texts t right join emails e on t.email_id = e.email_id and t.signup_action = 'CONFIRMED')
select round(sum(confirmed_users)/count(email_id),2) as confirm_rate
from cte;


-- Q98
CREATE TABLE tweets(
	tweet_id INT,
	user_id INT,
	tweet_date DATETIME
	);


INSERT INTO TWEETS VALUES
	(214252,111,'2022-06-01 12:00:00'),
	(739252,111,'2022-06-01 12:00:00'),
	(846402,111,'2022-06-02 12:00:00'),
	(241425,254,'2022-06-02 12:00:00'),
	(137374,111,'2022-06-04 12:00:00');

select * from TWEETS;

with cte as(
select user_id, tweet_date,
count(tweet_id) as cnt
from TWEETS
group by user_id, tweet_date
order by  user_id, tweet_date)
select user_id, tweet_date, round(avg(cnt) over(partition by user_id order by tweet_date rows between 2 preceding and current row),2) as rolling_avg_3days
from cte;


-- Q 99
CREATE TABLE activities(
	activity_id INT,
	user_id INT,
	activity_type ENUM('SEND','OPEN','CHAT'),
	time_spent FLOAT,
	activity_date varchar(25)
	);


INSERT INTO activities VALUES
	(7274,123,'OPEN',4.50,'06/22/2022 12:00:00'),
	(2425,123,'SEND',3.50,'06/22/2022 12:00:00'),
	(1413,456,'SEND',5.67,'06/23/2022 12:00:00'),
	(1414,789,'CHAT',11.00,'06/25/2022 12:00:00'),
	(2536,456,'OPEN',3.00,'06/25/2022 12:00:00');


CREATE TABLE age_breakdown(
        user_id INT,
        age_bucket ENUM('21-25','26-30','31-35')
	);


INSERT INTO age_breakdown VALUES
        (123,'31-35'),
        (456,'26-30'),
        (789,'21-25');
        
select * from activities;
select * from age_breakdown;

with cte as(
select user_id, activity_type, sum(time_spent) time_spent,
(case when activity_type = 'OPEN' then sum(time_spent) else 0 end) opening_snap,
(case when activity_type = 'SEND' then sum(time_spent) else 0 end) sending_snap
from 
activities 
where activity_type in ('OPEN', 'SEND')
group by user_id,activity_type
order by user_id),

temp as(
		select user_id,
        SUM(opening_snap) time_sending,
		SUM(sending_snap) time_opening
        from cte
        group by user_id)
        
select ab.age_bucket,
ROUND(time_sending * 100.0/(time_sending + time_opening),2) as open_perc,
ROUND(time_opening * 100.0/(time_sending + time_opening),2) as send_perc
from temp t join age_breakdown ab on t.user_id = ab.user_id
order by ab.age_bucket;

-- Q 100
CREATE TABLE personal_profiles(
	profile_id INT,
	name VARCHAR(20),
	followers INT
	);


INSERT INTO personal_profiles VALUES
	(1,'NICK SINGH',92000),
	(2,'ZACH WILSON',199000),
	(3,'DALIANA LIU',171000),
	(4,'RAVIT JAIN',107000),
	(5,'VIN VASHISHTA',139000),
	(6,'SUSAN WOJCICKI',39000);


CREATE TABLE employee_company(
	personal_profile_id INT,
	company_id INT
	);


INSERT INTO employee_company VALUES
	(1,4),
	(1,9),
	(2,2),
	(3,1),
	(4,3),
	(5,6),
	(6,5);


CREATE TABLE company_pages(
	company_id INT,
	name VARCHAR(30),
	followers INT
	);


INSERT INTO company_pages VALUES
	(1,'THE DATA SCIENCE PODCAST',8000),
	(2,'AIRBNB',700000),
	(3,'THE RAVIT SHOW',6000),
	(4,'DATA LEMUR',200),
	(5,'YOUTUBE',16000000),
	(6,'DATASCIENCE.VIN',4500),
	(9,'ACE THE DATA SCIENCE INTERVIEW',4479);
    
select * from personal_profiles;
select * from employee_company;
select * from company_pages;

select distinct p.profile_id
from personal_profiles p 
join employee_company e on p.profile_id = e.personal_profile_id
join company_pages c on c.company_id = e.company_id
where p.followers > c.followers
order by p.profile_id;
 


