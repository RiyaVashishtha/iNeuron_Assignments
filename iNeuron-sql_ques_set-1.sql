-- SQL QUES SET-> 1
-- Q1
select * from city
where COUNTRYCODE = 'USA' AND POPULATION >100000;

 -- Q2
 SELECT NAME FROM city
 where COUNTRYCODE = 'USA' AND POPULATION >120000;
 
-- Q3
select ID, NAME, COUNTRYCODE, DISTRICT, POPULATION
from city;

-- Q4
select ID, NAME, COUNTRYCODE, DISTRICT, POPULATION
from city
WHERE ID = 1661;

-- Q5
select ID, NAME, COUNTRYCODE, DISTRICT, POPULATION
from city
WHERE COUNTRYCODE = 'JPN';

-- Q6
SELECT NAME FROM city
WHERE COUNTRYCODE = 'JPN';

-- Q7
select city, state
from station;

-- Q8
SELECT distinct(city) from station
where id % 2 =0;

-- Q9
SELECT (count(city) - count(distinct(city))) as diff_city
from station;

-- Q10

SELECT 
  city 
FROM
(    
	(select 
			city,
			char_length(city) as city_length
			from station order by city_length desc
            limit 1)
UNION
	(select 
			city,
			char_length(city) as city_length
			from station order by city_length
            limit 1)
)smallest_largest_city;

-- approach 2
WITH temp_city AS (
					SELECT 
							city,
							LENGTH(city) as len,
							ROW_NUMBER() OVER (ORDER BY LENGTH(city), city) AS smallest,
							ROW_NUMBER() OVER (ORDER BY LENGTH(city) DESC, city) AS largest
					FROM 
							station
                )

SELECT 
        city,
        len
FROM 
        temp_city
WHERE  
        smallest = 1 
        OR 
        largest = 1
ORDER BY 
        len;
        
        
SELECt city, LENGTH(city) as len,
ROW_NUMBER() OVER (ORDER BY LENGTH(city), city) AS smallest
from station
order by len
limit 1;

-- Q11
SELECT DISTINCT(city)
from station
where city REGEXP '^[aeiou]';

-- Q12
SELECT DISTINCT(city)
from station
where city REGEXP '[aeiou]$';

-- Q13
SELECT DISTINCT(city)
from station
where city NOT REGEXP '^[aeiou]';

-- Q14
SELECT DISTINCT(city)
from station
where city NOT REGEXP '[aeiou]$';

-- Q15
-- approach 1
SELECT distinct(city)
from station
where city NOT regexp '^[aeiou]' or '[aeiou]$';

-- approach 2
select distinct(city)
from station
where 
left(lower(city),1) NOT IN ('a','e','i','o','u')
or right(lower(city),1) NOT IN ('a','e','i','o','u');

-- approach 3
SELECT distinct(city)
from station
where
substr(city,1,1) NOT IN ('A','E','I','O','U')
OR substr(city,-1,1) NOT IN ('A','E','I','O','U');

-- Q16
SELECT distinct(city)
from station
where
substr(city,1,1) NOT IN ('A','E','I','O','U')
AND substr(city,-1,1) NOT IN ('A','E','I','O','U');

-- Q 17
CREATE TABLE product
(
  product_id INT,
  product_name VARCHAR(30),
  unit_price INT,
  CONSTRAINT pk_product PRIMARY KEY (product_id)
);

CREATE TABLE sales
(
  seller_id INT,
  product_id INT,
  buyer_id INT,
  sale_date DATE,
  quantity INT,
  price INT,
  CONSTRAINT fk_product FOREIGN KEY (product_id)
    REFERENCES product(product_id) 
);


INSERT INTO product VALUES(1, 'S8', 1000);
INSERT INTO product VALUES(2, 'G4', 800);
INSERT INTO product VALUES(3, 'iPhone', 1400);

INSERT INTO sales VALUES(1, 1, 1, '2019-01-21', 2, 2000);
INSERT INTO sales VALUES(1, 2, 2, '2019-02-17', 1, 800);
INSERT INTO sales VALUES(2, 2, 3, '2019-06-02', 1, 800);
INSERT INTO sales VALUES(3, 3, 4, '2019-05-13', 2, 2800);


SELECT
  p.product_id,
  p.product_name
FROM
  sales s
  JOIN product p ON p.product_id = s.product_id
WHERE
  s.sale_date >= STR_TO_DATE('2019-01-01', '%Y-%m-%d')
  AND s.sale_date <= STR_TO_DATE('2019-03-31', '%Y-%m-%d')
  AND NOT EXISTS(
    SELECT
      *
    FROM
      sales s2
    WHERE
      s.product_id = s2.product_id
      AND (s2.sale_date < STR_TO_DATE('2019-01-01', '%Y-%m-%d')
      OR s2.sale_date > STR_TO_DATE('2019-03-31', '%Y-%m-%d'))
  )
;

-- Q18
CREATE TABLE views
(
  article_id INT,
  author_id INT,
  viewer_id INT,
  viewer_date DATE
);

INSERT INTO views VALUES(1, 3, 5, '2019-08-01');
INSERT INTO views VALUES(1, 3, 6, '2019-08-02');
INSERT INTO views VALUES(2, 7, 7, '2019-08-01');
INSERT INTO views VALUES(2, 7, 6, '2019-08-02');
INSERT INTO views VALUES(4, 7, 1, '2019-07-22');
INSERT INTO views VALUES(3, 4, 4, '2019-07-21');
INSERT INTO views VALUES(3, 4, 4, '2019-07-21');

select * FROM views;

select distinct(v.author_id) as id
from views v
where EXISTS(
	select * from views s
    where v.author_id = s.viewer_id)
order by v.author_id;
    
-- approach 2
select distinct(author_id) as id
from views
where author_id = viewer_id
order by id;

-- Q 19
CREATE TABLE delivery
(
  delivery_id INT,
  customer_id INT,
  order_date DATE,
  customer_pref_delivery_date DATE
);

INSERT INTO delivery VALUES(1, 1, '2019-08-01', '2019-08-02');
INSERT INTO delivery VALUES(2, 5, '2019-08-02', '2019-08-02');
INSERT INTO delivery VALUES(3, 1, '2019-08-11', '2019-08-11');
INSERT INTO delivery VALUES(4, 3, '2019-08-24', '2019-08-26');
INSERT INTO delivery VALUES(5, 4, '2019-08-21', '2019-08-22');
INSERT INTO delivery VALUES(6, 2, '2019-08-11', '2019-08-13');

select * from delivery;

select ROUND(
	   COUNT(
       CASE WHEN order_date = customer_pref_delivery_date then 1 end)* 100/count(*),2) as immediate_percentage
from delivery;

-- Q20
CREATE TABLE ads
(
  ad_id INT,
  user_id INT,
  action ENUM('Clicked', 'Viewed', 'Ignored'),
  CONSTRAINT pk_ads PRIMARY KEY(ad_id, user_id)
);

INSERT INTO ads VALUES(1, 1, 'Clicked');
INSERT INTO ads VALUES(2, 2, 'Clicked');
INSERT INTO ads VALUES(3, 3, 'Viewed');
INSERT INTO ads VALUES(5, 5, 'Ignored');
INSERT INTO ads VALUES(1, 7, 'Ignored');
INSERT INTO ads VALUES(2, 7, 'Viewed');
INSERT INTO ads VALUES(3, 5, 'Clicked');
INSERT INTO ads VALUES(1, 4, 'Viewed');
INSERT INTO ads VALUES(2, 11, 'Viewed');
INSERT INTO ads VALUES(1, 2, 'Clicked');

select * from ads;

WITH ADS_CTR AS(
select ad_id,
	   COUNT(
       CASE WHEN action = 'Clicked' then 1 end) as clicked_count,
       COUNT(
       CASE WHEN action = 'Viewed' then 1 end) as viewed_count,
       COUNT(
       CASE WHEN action = 'Ignored' then 1 end) as ignored_count
from ads
group by ad_id)

SELECT ad_id,
CASE WHEN clicked_count + viewed_count = 0 then 0
else
ROUND((clicked_count *100/(clicked_count + viewed_count)),2) end as ctr
from ADS_CTR
order by ad_id;


-- Q21
CREATE TABLE employee
(
  employee_id INT,
  team_id INT,
  CONSTRAINT pk_employee PRIMARY KEY(employee_id)
);

INSERT INTO employee VALUES
        (1,8),
        (2,8),
        (3,8),
        (4,7),
        (5,9),
        (6,9);

drop table employee;
select * from employee;

select employee_id,
      count(*) over(partition by team_id) as team_size
from employee
order by employee_id;

-- Q22
CREATE TABLE countries
(
  country_id INT,
  country_name VARCHAR(30),
  CONSTRAINT pk_country PRIMARY KEY(country_id)
);

CREATE TABLE weather
(
  country_id INT,
  weather_state INT,
  day DATE,
  CONSTRAINT pk_weather PRIMARY KEY(country_id, day)
);

INSERT INTO countries VALUES(2, 'USA');
INSERT INTO countries VALUES(3, 'Australia');
INSERT INTO countries VALUES(7, 'Peru');
INSERT INTO countries VALUES(5, 'China');
INSERT INTO countries VALUES(8, 'Morocco');
INSERT INTO countries VALUES(9, 'Spain');

INSERT INTO weather VALUES(2, 15, '2019-11-01');
INSERT INTO weather VALUES(2, 12, '2019-10-28');
INSERT INTO weather VALUES(2, 12, '2019-10-27');
INSERT INTO weather VALUES(3, -2, '2019-11-10');
INSERT INTO weather VALUES(3, 0, '2019-11-11');
INSERT INTO weather VALUES(3, 3, '2019-11-12');
INSERT INTO weather VALUES(5, 16, '2019-11-07');
INSERT INTO weather VALUES(5, 18, '2019-11-09');
INSERT INTO weather VALUES(5, 21, '2019-11-23');
INSERT INTO weather VALUES(7, 25 , '2019-11-28');
INSERT INTO weather VALUES(7 , 22, '2019-12-01');
INSERT INTO weather VALUES(7, 20, '2019-12-02');
INSERT INTO weather VALUES(8, 25, '2019-11-05');
INSERT INTO weather VALUES(8, 27, '2019-11-15');
INSERT INTO weather VALUES(8, 31, '2019-11-25');
INSERT INTO weather VALUES(9, 7, '2019-10-23');
INSERT INTO weather VALUES(9, 3, '2019-12-23');

select * from weather;

-- practice
select distinct(c.country_name),
sum(w.weather_state) over(partition by w.country_id) as weather_type
from weather w join countries c on c.country_id = w.country_id
where 
  DATE_FORMAT(w.day, '%Y-%m') = '2019-11';
  
-- soln ques 22
select c.country_name,
		avg(weather_state) as avg_w,
	   CASE WHEN avg(weather_state) <=15 THEN 'Cold'
       WHEN avg(weather_state)>= 25 then 'Hot'
       else 'Warm' end as weather_type
from weather w join countries c on w.country_id = c.country_id
WHERE
  DATE_FORMAT(w.day, '%Y-%m') = '2019-11'
group by c.country_id,
		 c.country_name;
         
-- Q23
CREATE TABLE prices
(
  product_id INT,
  start_date DATE,
  end_date DATE,
  price INT,
  CONSTRAINT pk_prices PRIMARY KEY(product_id, start_date, end_date)
);

CREATE TABLE units_sold
(
  product_id INT,
  purchase_date DATE,
  units INT
);

INSERT INTO prices VALUES(1, '2019-02-17', '2019-02-28', 5);
INSERT INTO prices VALUES(1, '2019-03-01', '2019-03-22', 20);
INSERT INTO prices VALUES(2, '2019-02-01', '2019-02-20', 15);
INSERT INTO prices VALUES(2, '2019-02-21', '2019-03-31', 30);

INSERT INTO units_sold VALUES(1, '2019-02-25', 100);
INSERT INTO units_sold VALUES(1, '2019-03-01', 15);
INSERT INTO units_sold VALUES(2, '2019-02-10', 200);
INSERT INTO units_sold VALUES(2, '2019-03-22', 30);

SELECT * FROM units_sold;

select u.product_id,
	  round(sum(u.units * p.price)/sum(u.units),2) as average_price
from units_sold u join prices p on u.product_id = p.product_id
where u.purchase_date between p.start_date and p.end_date
group by u.product_id;

-- Q24
CREATE TABLE activity
(
  player_id INT,
  device_id INT,
  event_date DATE,
  games_played INT,
  CONSTRAINT pk_activity PRIMARY KEY(player_id, event_date)
);

INSERT INTO activity VALUES(1, 2, '2016-03-01', 5);
INSERT INTO activity VALUES(1, 2, '2016-05-02', 6);
INSERT INTO activity VALUES(2, 3, '2017-06-25', 1);
INSERT INTO activity VALUES(3, 1, '2016-03-02', 0);
INSERT INTO activity VALUES(3, 4, '2018-07-03', 5);

select * from activity;
-- Approach 1
select distinct(player_id),
first_value(event_date) over(partition by player_id order by event_date) as first_login
from activity;

-- Approach 2
WITH CTE AS(
	select distinct(player_id),event_date as first_login,
	dense_rank() over(partition by player_id order by event_date) as rnk
from activity)
select player_id, first_login
from CTE
where rnk = 1;

-- Q25
select distinct(player_id),
first_value(device_id ) over(partition by player_id order by event_date) as device_id
from activity;

-- Q26
CREATE TABLE products
(
  product_id INT,
  product_name VARCHAR(30),
  product_category VARCHAR(30),
  CONSTRAINT pk_products PRIMARY KEY(product_id)
);

CREATE TABLE orders(
        product_id INT,
        order_date DATE,
        unit INT,
        CONSTRAINT foriegn_key FOREIGN KEY(product_id) REFERENCES products(product_id)
	);

INSERT INTO products VALUES(1, 'Leetcode Solutions', 'Book');
INSERT INTO products VALUES(2, 'Jewels of Stringology', 'Book');
INSERT INTO products VALUES(3, 'HP', 'Laptop');
INSERT INTO products VALUES(4, 'Lenovo', 'Laptop');
INSERT INTO products VALUES(5, 'Leetcode Kit', 'T-shirt');

INSERT INTO orders VALUES(1, '2020-02-05', 60);
INSERT INTO orders VALUES(1, '2020-02-10', 70);
INSERT INTO orders VALUES(2, '2020-01-18', 30);
INSERT INTO orders VALUES(2, '2020-02-11' ,80);
INSERT INTO orders VALUES(3, '2020-02-17', 2);
INSERT INTO orders VALUES(3, '2020-02-24', 3);
INSERT INTO orders VALUES(4, '2020-03-01', 20);
INSERT INTO orders VALUES(4, '2020-03-04', 30);
INSERT INTO orders VALUES(4, '2020-03-04', 60);
INSERT INTO orders VALUES(5, '2020-02-25', 50);
INSERT INTO orders VALUES(5, '2020-02-27', 50);
INSERT INTO orders VALUES(5, '2020-03-01', 50);

select * from orders;
WITH CTE AS(
select distinct(p.product_name) as product_name,
	    sum(
       CASE WHEN order_date between '2020-02-01' and '2020-02-28' then unit end) as units_sold
from orders o join products p on o.product_id = p.product_id
group by p.product_name)
select distinct(product_name),
		units_sold
from CTE
where units_sold >= 100;

-- Q27
CREATE TABLE users
(
  user_id INT,
  name VARCHAR(30),
  mail VARCHAR(50),
  CONSTRAINT pk_users PRIMARY KEY(user_id)
);


INSERT INTO users VALUES(1, 'Winston', 'winston@leetcode.com');
INSERT INTO users VALUES(2, 'Jonathan', 'jonathanisgreat');
INSERT INTO users VALUES(3, 'Annabelle', 'bella-@leetcode.com');
INSERT INTO users VALUES(4, 'Sally', 'sally.come@leetcode.com');
INSERT INTO users VALUES(5, 'Marwan', 'quarz#2020@le etcode.com');
INSERT INTO users VALUES(6, 'David', 'david69@gmail.com');
INSERT INTO users VALUES(7, 'Shapiro','.shapo@leetco de.com');

select * from users;
select *
from users
where REGEXP_LIKE(mail, '^[a-zA-Z][a-zA-Z0-9\_\.\-]*@leetcode.com');

-- Q28
DROP table customers;
CREATE TABLE customers(
        customer_id INT,
        name VARCHAR(20),
        country VARCHAR(20),
        CONSTRAINT prime_key PRIMARY KEY(customer_id)
	);


CREATE TABLE orderss(
        order_id INT,
        customer_id INT,
        product_id INT,
        order_date DATE,
        quantity INT,
        CONSTRAINT prime_key PRIMARY KEY(order_id)
	);


CREATE TABLE productss(
        product_id INT,
        description VARCHAR(20),
        price INT,
        CONSTRAINT prime_key PRIMARY KEY(product_id)
	);


INSERT INTO customers VALUES 
        (1,'WINSTON','USA'),
        (2,'JONATHON','PERU'),
        (3,'MOUSTAFA','EGYPT');


INSERT INTO productss VALUES 
        (10,'LC PHONE',300),
        (20,'LC T-SHIRT',10),
        (30,'LC BOOK',45),
        (40,'LC KEYCHAIN',2);


INSERT INTO orderss VALUES 
        (1,1,10,'2020-06-10',1),
        (2,1,20,'2020-07-01',1),
        (3,1,30,'2020-07-08',2),
        (4,2,10,'2020-06-15',2),
        (5,2,40,'2020-07-01',10),
        (6,3,20,'2020-06-24',2),
        (7,3,30,'2020-06-25',2),
        (9,3,30,'2020-05-08',3);
        
select * from orderss;

select o.customer_id,
		c.name
from orderss o join productss p on o.product_id = p.product_id
			   join customers c on c.customer_id = o.customer_id
group by o.customer_id
having(
sum(case when o.order_date like '2020-06%' then o.quantity * p.price
else 0 end)>=100
and 
sum(case when o.order_date like '2020-07%' then o.quantity * p.price
else 0 end)>=100
);


-- Q 29
CREATE TABLE tv_program(
        program_date DATETIME,
        content_id INT,
        channel VARCHAR(20),
        CONSTRAINT prime_key PRIMARY KEY(program_date, content_id)
);


CREATE TABLE content(
        content_id INT,
        title VARCHAR(20),
        kids_content ENUM('Y','N'),
        content_type VARCHAR(20),
        CONSTRAINT prime_key PRIMARY KEY(content_id)
);


INSERT INTO content VALUES
        (1,'LEETCODE MOVIE', 'N','MOVIES'),
        (2,'ALG. FOR KidS', 'Y','SERIES'),
        (3,'DATABASE SOLS', 'N','SERIES'),
        (4,'ALADDIN', 'Y','MOVIES'),
        (5,'CINDERELLA', 'Y','MOVIES');
        

INSERT INTO tv_program VALUES
		('2020-06-10 18:00',1,'LC-channel'),
        ('2020-05-11 12:00',2,'LC-channel'),
        ('2020-05-12 12:00',3,'LC-channel'),
        ('2020-05-13 14:00',4,'DISNEY-CH'),
        ('2020-06-18 14:00',4,'DISNEY-CH'),
        ('2020-07-15 16:00',5,'DISNEY-CH');
        
select * from content;
select c.title
from content c join tv_program t on c.content_id = t.content_id
where c.kids_content = 'Y' and t.program_date like '2020-06%';

-- Q30

CREATE TABLE npv(
        id INT,
        year INT,
        npv INT,
        CONSTRAINT prime_key PRIMARY KEY(id, year)
	);


CREATE TABLE queries(
        id INT,
        year INT,
        CONSTRAINT prime_key PRIMARY KEY(id, year)
	);


INSERT INTO npv VALUES
        (1,2018,100),
        (7,2020,30),
        (13,2019,40),
        (1,2019,113),
        (2,2008,121),
        (3,2009,12),
        (11,2020,99),
        (7,2019,0);


INSERT INTO queries VALUES
        (1,2019),
        (2,2008),
        (3,2009),
        (7,2018),
        (7,2019),
        (7,2020),
        (13,2019);
        
select * from queries;
select * from npv;
select q.id,q.year, 
	  ifnull(n.npv,0)
from queries q left join npv n on q.id = n.id and q.year = n.year;

-- Q31
-- same as q31

-- Q32

CREATE TABLE employees(
		id INT,
		name VARCHAR(20),
		CONSTRAINT prime_key PRIMARY KEY(id)
	);


CREATE TABLE employees_uni(
		id INT,
		unique_id INT,
		CONSTRAINT prime_key PRIMARY KEY(id, unique_id)
	);


INSERT INTO employees VALUES
		(1,'ALICE'),
		(7,'BOB'),
		(11,'MEIR'),
		(90,'WINSTON'),
		(3,'JONATHAN');


INSERT INTO employees_uni VALUES
		(3,1),
		(11,2),
		(90,3);
select * from employees_uni;
select * from employees;

select u.unique_id,
	   e.name
from employees_uni u right join employees e on u.id = e.id;

-- Q33
CREATE TABLE users_tbl(
		id INT,
		name VARCHAR(20),
		CONSTRAINT prime_key PRIMARY KEY(id)
	);


INSERT INTO users_tbl VALUES
		(1,'ALICE'),
		(2,'BOB'),
		(3,'ALEX'),
		(4,'DONALD'),
		(7,'LEE'),
		(13,'JONATHON'),
		(19,'ELVIS');


CREATE TABLE rides(
        id INT,
        user_id INT,
        distance INT,
        CONSTRAINT prime_key PRIMARY KEY(id)
	);


INSERT INTO rides VALUES
        (1,1,120),
        (2,2,317),
        (3,3,222),
        (4,7,100),
        (5,13,312),
        (6,19,50),
        (7,7,120),
        (8,19,400),
        (9,7,230);
        
select * from rides;
select * from users_tbl;

select u.name,
	  ifnull(sum(r.distance),0) as travelled_distance
from rides r right join users_tbl u on r.user_id = u.id
group by u.name
order by travelled_distance desc, name;

-- 	Q34
-- same as Q26
-- Q35
CREATE TABLE user_tbl(
		user_id INT,
		name VARCHAR(20),
		CONSTRAINT prime_key PRIMARY KEY(user_id)
	);


INSERT INTO user_tbl VALUES
		(1,'DANIEL'),
		(2,'MONICA'),
		(3,'MARIA'),
		(4,'JAMES');


CREATE TABLE movies(
		movie_id INT,
		title VARCHAR(20),
		CONSTRAINT prime_key PRIMARY KEY(movie_id)
	);


INSERT INTO movies VALUES
		(1,'AVENGERS'),
		(2,'FROZEN 2'),
		(3,'JOKER');


CREATE TABLE movie_rating(
		movie_id INT,
		user_id INT,
		rating INT,
		created_at DATE,
		CONSTRAINT prime_key PRIMARY KEY(movie_id, user_id)
	);


INSERT INTO movie_rating VALUES
		(1,1,3,'2020-01-12'),
		(1,2,4,'2020-02-11'),
		(1,3,2,'2020-02-12'),
		(1,4,1,'2020-01-01'),
		(2,1,5,'2020-02-17'),
		(2,2,2,'2020-02-01'),
		(2,3,2,'2020-03-01'),
		(3,1,3,'2020-02-22'),
		(3,2,4,'2020-02-25');

select * from movie_rating;
select * from movies;
select * from user_tbl;
-- Find the name of the user who has rated the greatest number of movies

(select u.name as result
from movie_rating r join user_tbl u on r.user_id = u.user_id
group by u.user_id,u.name
order by count(*) desc,u.name
limit 1)
UNION ALL
(select m.title as result
from movie_rating r join movies m on r.movie_id = m.movie_id
where DATE_FORMAT(r.created_at, '%Y-%m') = '2020-02'
group by r.movie_id, m.title
order by avg(rating) desc, m.title
limit 1);

-- Q36 SAME AS Q33
-- Q37 SAME AS 32

-- Q38

CREATE TABLE departments(
		id INT,
		name VARCHAR(25),
		CONSTRAINT prime_key PRIMARY KEY(id)
	);

INSERT INTO departments VALUES
		(1,'ELECTRICAL ENGINEERING'),
		(7,'COMPUTER ENGINEERING'),
		(13,'BUSINESS ADMINISTRATION');

CREATE TABLE students(
		id INT,
		name VARCHAR(25),
		department_id INT,
		CONSTRAINT prime_key PRIMARY KEY(id)
	);


INSERT INTO students VALUES
		(23,'ALICE',1),
		(1,'BOB',7),
		(5,'JENNIFER',13),
		(2,'JOHN',14),
		(4,'JASMINE',77),
		(3,'STEVE',74),
		(6,'LUIS',1),
		(8,'JONATHON',7),
		(7,'DAIANA',33),
		(11,'MADELYNN',1);

SELECT * FROM students;
select * from departments;

select s.id,
		s.name
from students s left join departments d on s.department_id = d.id
where d.id is null;

-- Q39
CREATE TABLE calls(
		from_id INT,
		to_id INT,
		duration INT
	);


INSERT INTO calls VALUES
		(1,2,59),
		(2,1,11),
		(1,3,20),
		(3,4,100),
		(3,4,200),
		(3,4,200),
		(4,3,499);

select * from calls;

-- approach 1

select least(from_id, to_id) as Person1,
		greatest(from_id,to_id) as Person2,
        count(*) as call_count,
        sum(duration) as total_duration
from calls
group by Person1, Person2;

-- approach 2

select
		case when from_id < to_id then from_id
        else to_id end as Person1,
        case when from_id < to_id then to_id
        else from_id end as Person2,
        count(*) as call_count,
        sum(duration) as total_duration
from calls
group by Person1, Person2;

-- Q40 same as Q23

-- Q41
CREATE TABLE warehouse(
		name VARCHAR(25),
		product_id INT,
		units INT,
		CONSTRAINT prime_key PRIMARY KEY(name,product_id)
	);

INSERT INTO warehouse VALUES
		('LCHOUSE1',1,1),
		('LCHOUSE1',2,10),
		('LCHOUSE1',3,5),
		('LCHOUSE2',1,2),
		('LCHOUSE2',2,2),
		('LCHOUSE3',4,1);

CREATE TABLE products_tbl(
		product_id INT,
		product_name VARCHAR(25),
		width INT,
		length INT,
		height INT,
		CONSTRAINT prime_key PRIMARY KEY(product_id)
	);

INSERT INTO products_tbl VALUES
		(1,'LC-TV',5,50,40),
		(2,'LC-KEYCHAIN',5,5,5),
		(3,'LC-PHONE',2,10,10),
		(4,'LC-SHIRT',4,10,20);
        
select * from products_tbl;
select * from warehouse;

select w.name as warehouse_name,
		sum(p.width * p.length * p.height *w.units) as volume
from products_tbl p join warehouse w on p.product_id = w.product_id
group by w.name;

-- Q42
CREATE TABLE sales_tbl(
		sale_date DATE,
		fruit ENUM('APPLES','ORANGES'),
		sold_num INT,
		CONSTRAINT prime_key PRIMARY KEY(sale_date,fruit)
	);
INSERT INTO sales_tbl VALUES
		('2020-05-01','APPLES',10),
		('2020-05-01','ORANGES',8),
		('2020-05-02','APPLES',15),
		('2020-05-02','ORANGES',15),
		('2020-05-03','APPLES',20),
		('2020-05-03','ORANGES',0),
		('2020-05-04','APPLES',15),
		('2020-05-04','ORANGES',16);
        
select * from sales_tbl;
SELECT
		sale_date,
        SUM(
			CASE
			WHEN fruit = 'APPLES' THEN sold_num
			WHEN fruit = 'ORANGES' THEN -sold_num
			END 
			) AS difference
FROM 
		sales_tbl
GROUP BY 
		sale_date
ORDER BY 
		sale_date;
        
-- approach 2
select sale_date,difference
from(
		select sale_date,
				sold_num - lead(sold_num,1) over(partition by sale_date order by sale_date) as difference
                from sales_tbl) temp_sales
where difference is not null
order by sale_date;

-- Q 43
select * from activity;

with temp_activity as(
					select player_id,
							lead(event_date,1) over(partition by player_id order by event_date) - event_date as difference
					from activity),
		temp_activity2 as(
					select count(distinct player_id) as player_count
                    from temp_activity
                    where difference = 1
                    group by player_id)
select round(count(*)/(select count(distinct player_id) from activity),2) as fraction
from temp_activity2;


-- Q44
CREATE TABLE employee_tb(
		id INT,
		name VARCHAR(20),
		department VARCHAR(20),
		manager_id INT,
		CONSTRAINT prime_key PRIMARY KEY(id)
	);


INSERT INTO employee_tb VALUES 
		(101,'JOHN','A',NULL),
		(102,'DAN','A',101),
		(103,'JAMES','A',101),
		(104,'AMY','A',101),
		(105,'ANNE','A',101),
		(106,'RON','A',101),
		(107,'BUTTLER','A',111),
		(108,'JIMMY','A',121),
		(111,'ROOT','A',NULL),
		(121,'POPE','A',NULL);
        
select * from employee_tb;

select name 
from employee_tb 
where id = (
			select manager_id from employee_tb  group by manager_id having count(manager_id)>=5);
            

-- Q45

CREATE TABLE department
(
  dept_id INT,
  dept_name VARCHAR(30),
  CONSTRAINT pk_department PRIMARY KEY(dept_id)
);

CREATE TABLE student
(
  student_id INT,
  student_name VARCHAR(30),
  gender VARCHAR(1),
  dept_id INT,
  CONSTRAINT pk_student PRIMARY KEY(student_id),
  CONSTRAINT fk_department FOREIGN KEY (dept_id)
    REFERENCES department(dept_id) 
);

INSERT INTO department VALUES(1, 'Engineering');
INSERT INTO department VALUES(2, 'Science');
INSERT INTO department VALUES(3, 'Law');

INSERT INTO student VALUES(1, 'Jack', 'M', 1);
INSERT INTO student VALUES(2, 'Jane', 'F', 1);
INSERT INTO student VALUES(3, 'Mark', 'M', 2);

select * from student;
select * from department;

select d.dept_name,
		count(
			case when s.dept_id is not null then d.dept_id end) as student_number
from department d left join student s on d.dept_id = s.dept_id
group by d.dept_id, d.dept_name
order by student_number desc, d.dept_name;

-- Q46
CREATE TABLE customer(
		customer_id INT,
		product_key INT
	);
INSERT INTO customer VALUES 
		(1,5),
		(2,6),
		(3,5),
		(3,6),
		(1,6);

CREATE TABLE product_tbl(
		product_key INT,
		CONSTRAINT prime_key PRIMARY KEY(product_key)
	);
INSERT INTO product_tbl VALUES 
		(5),
		(6);

select * from product_tbl;
select * from customer;

select customer_id from customer
group by customer_id
having count(distinct product_key) = (select count(*) from product_tbl);

-- Q 47
CREATE TABLE employee_T(
		employee_id INT,
		name VARCHAR(20),
		experience_years INT,
		CONSTRAINT prime_key PRIMARY KEY(employee_id)
	);


CREATE TABLE project(
		project_id INT,
		employee_id INT,
		CONSTRAINT prime_key PRIMARY KEY(project_id, employee_id)
	);


INSERT INTO employee_T VALUES 
		(1,'KHALED',3),
		(2,'ALI',2),
		(3,'JOHN',3),
		(4,'DOE',2);
INSERT INTO project VALUES 
		(1,1),
		(1,2),
		(1,3),
		(2,1),
		(2,4);
        
select * from employee_T;
select * from project;

select p.project_id,
		e.employee_id
from project p join employee_T e on p.employee_id = e.employee_id
where e.experience_years = (select max(experience_years) from employee_T);

-- approach 2
select project_id, employee_id
from(
select p.project_id,
		e.employee_id,e.experience_years,
        dense_rank() over(partition by p.project_id order by e.experience_years desc) as exp
from project p join employee_T e on p.employee_id = e.employee_id) temp_exp
where exp = 1;

-- Q 48
drop table books;

CREATE TABLE books
(
  book_id INT,
  name VARCHAR(30),
  avaialable_from DATE,
  CONSTRAINT pk_books PRIMARY KEY(book_id)
);

CREATE TABLE order_tb
(
  order_id INT,
  book_id INT,
  quantity INT,
  dispatch_date DATE,
  CONSTRAINT pk_orders PRIMARY KEY(order_id),
  CONSTRAINT fk_orders FOREIGN KEY (book_id)
    REFERENCES books(book_id) 
);

INSERT INTO books VALUES(1, 'Kalila And Demna', '2010-01-01');
INSERT INTO books VALUES(2, '28 Letters', '2012-05-12');
INSERT INTO books VALUES(3, 'The Hobbit', '2019-06-10');
INSERT INTO books VALUES(4, '13 Reasons Why', '2019-06-01');
INSERT INTO books VALUES(5, 'The Hunger Games', '2008-09-21');
			
			
select * from books;

-- Q 49
CREATE TABLE enrollments(
		student_id INT,
		course_id INT,
		grade INT,
		CONSTRAINT prime_key PRIMARY KEY(student_id,course_id)
    );


INSERT INTO enrollments VALUES 
		(2,2,95),
		(2,3,95),
		(1,1,90),
		(1,2,99),
		(3,1,80),
		(3,2,75),
		(3,3,82);

select * from enrollments;

select student_id, course_id,grade
from (	select student_id, course_id, grade,
        row_number() over(partition by student_id order by grade desc, course_id) as ranking from enrollments) temp_enroll
where ranking =1;

-- Q 50
CREATE TABLE players
(
  player_id INT,
  group_id INT,
  CONSTRAINT pk_players PRIMARY KEY(player_id)
);

CREATE TABLE matches
(
  match_id INT,
  first_player INT,
  second_player INT,
  first_score INT,
  second_score INT,
  CONSTRAINT pk_matches PRIMARY KEY(match_id)
);

INSERT INTO players VALUES(15, 1);
INSERT INTO players VALUES(25, 1);
INSERT INTO players VALUES(30, 1);
INSERT INTO players VALUES(45, 1);
INSERT INTO players VALUES(10, 2);
INSERT INTO players VALUES(35, 2);
INSERT INTO players VALUES(50, 2);
INSERT INTO players VALUES(20, 3);
INSERT INTO players VALUES(40, 3);

INSERT INTO matches VALUES(1, 15, 45, 3, 0);
INSERT INTO matches VALUES(2, 30, 25, 1, 2);
INSERT INTO matches VALUES(3, 30, 15, 2, 0);
INSERT INTO matches VALUES(4, 40, 20, 5, 2);
INSERT INTO matches VALUES(5, 35, 50, 1, 1);

select * from players;
select * from matches;

with player_score as(
					select p.player_id,
						   p.group_id,
                           sum(case when p.player_id = m.first_player then m.first_score
								when p.player_id = m.second_player then m.second_score end) as score
					from players p join matches m on p.player_id = m.first_player or p.player_id = m.second_player
                    group by p.group_id,p.player_id),
                    
	player_rank as(
					select player_id,
						   group_id,
                           dense_rank() over(partition by group_id order by score desc, player_id) as player_rnk
					from player_score)
                    
select group_id, player_id
from player_rank
where player_rnk = 1;

-------------------------------------
-- set2
-- Q 51
CREATE TABLE world
(
  name VARCHAR(25),
  continent VARCHAR(10),
  area INT,
  population INT,
  gdp BIGINT,
  CONSTRAINT pk_world PRIMARY KEY (name)
);

INSERT INTO world VALUES('Afghanistan', 'Asia', 652230, 25500100, 20343000000);
INSERT INTO world VALUES('Albania', 'Europe', 28748, 2831741, 12960000000);
INSERT INTO world VALUES('Algeria', 'Africa', 2381741, 37100000, 188681000000);
INSERT INTO world VALUES('Andorra', 'Europe', 468, 78115, 3712000000);
INSERT INTO world VALUES('Angola', 'Africa', 1246700, 20609294, 100990000000);

select * from world;

select name, population,area
from world
where area>=3000000 or population >= 25000000;

-- Q 52
create table customer_tbl
(
id INT,
name varchar(10),
referee_id bigint,
constraint pk_customer PRIMARY KEY (id)
);

INSERT INTO customer_tbl VALUES(1, 'Will', null)
						,(2, 'Jane', null)
						,(3, 'Alex', 2)
						,(4, 'Bill', null)
						,(5, 'Zack', 1)
						,(6, 'Mark', 2);
                        
select * from customer_tbl;

select name from customer_tbl where referee_id is null or referee_id = 1;





                    
				
                    
        