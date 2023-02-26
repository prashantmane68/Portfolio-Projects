use PortfolioProject_ZomatoAnalytics

drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
        (3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
		(2,'01-15-2015'),
		(3,'04-11-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
		(3,'12-18-2019',1),
		(2,'07-20-2020',3),
		(1,'10-23-2019',2),
		(1,'03-19-2018',3),
		(3,'12-20-2016',2),
		(1,'11-09-2016',1),
		(1,'05-20-2016',3),
		(2,'09-24-2017',1),
		(1,'03-11-2017',2),
		(1,'03-11-2016',1),
		(3,'11-10-2016',1),
		(3,'12-07-2017',2),
		(3,'12-15-2016',2),
		(2,'11-08-2017',2),
		(2,'09-10-2018',3);

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer);

INSERT INTO product(product_id,product_name,price) 
 VALUES
		(1,'p1',980),
		(2,'p2',870),
		(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

1.  What is the Total Amount each customer spent on Zomato ?

select s.userid, SUM(p.price) as total_amt_spent from sales s inner join product p
on s.product_id = p.product_id group by userid;

2.  How many days each customer has visited Zomato ?

select userid, count(distinct created_date) as distinct_days from sales group by userid;

3.  What was the first product purchased by each customer ?

select * from
(select *, rank() over (partition by userid order by created_date asc) as rnk from sales) a
where rnk = 1;

4. What was the most puchased item on the menu and how many times was it purchased by all customers ?

select userid, product_id,count(product_id) as cnt from sales where product_id =
(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid, product_id;


5. Each User wise which is the most favourite item ?

select userid, product_id,cnt from
(select *, rank() over (partition by userid order by cnt desc) as rnk from 
(select userid, product_id, count(product_id) as cnt from sales group by userid, product_id) a) b
where rnk =1;

6. Which item was first purchased by customer after they became a member ?

select * from 
(select *, rank() over (partition by userid order by created_date) as rnk from
(select s.*, g.gold_signup_date from sales s inner join
goldusers_signup g on s.userid = g.userid and created_date >= gold_signup_date) a) b
where rnk = 1;

7.  Which item was purchased just before the customer became a member ?

select * from 
(select *, rank() over (partition by userid order by created_date desc) as rnk from
(select s.*, g.gold_signup_date from sales s inner join
goldusers_signup g on s.userid = g.userid and created_date <= gold_signup_date) a) b
where rnk = 1;

8. What is the Total orders and amount spent for each member before they became a member ?

select b.userid, count(created_date) as orders, sum(price) as amt_spent from
(select a.*, p.price from 
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales s inner join goldusers_signup g
on s.userid = g.userid and created_date < gold_signup_date) a
inner join product p on a.product_id = p.product_id) b
group by b.userid ;


9. If buying each product generates points for eg  5rs = 2 zomato points and each product has different purchasing points 
    for eg. for p1 5rs = 1 Zomato point, for p2 10rs = 5 zomato points and p3 5rs = 1 zomato point
	Calculate points collected by each customers and for which product most points given till now.
	
p1 = 5rs = 1 zomato point
p2 = 2rs = 1 zomato point
p3 = 5rs = 1 zomato point

>>> points collected by each customers :

select c.userid, sum(Total_points) as total_points_earned from 
(select userid, product_id, amt/points as Total_points from
(select a.*, case when product_id = 1 then 5 
			when product_id = 2 then 2
			when product_id = 3 then 5
			else 0 end as points from
(select s.userid,s.product_id,sum(p.price) as amt from sales s inner join product p
on s.product_id = p.product_id group by s.userid,s.product_id) a) b) c
group by c.userid;

>>> product most points given

select e.* from 
(select d.*, rank() over (order by total_points_given desc) as rnk from
(select c.product_id, sum(Total_points) as total_points_given from
(select userid, product_id, amt/points as Total_points from
(select a.*, case when product_id = 1 then 5 
			when product_id = 2 then 2
			when product_id = 3 then 5
			else 0 end as points from
(select s.userid,s.product_id,sum(p.price) as amt from sales s inner join product p
on s.product_id = p.product_id group by s.userid,s.product_id) a) b) c
group by c.product_id) d) e
where rnk = 1;


10.  In the first year after customer joins gold program (including their join date) irrespective of 
what the customer has purchased they earn 5 points for every 10 rs spent.  who earned more , customer 1 or 3 ?
and what was their points earnings in their first yr ?

2Rs = 1 zomato point

select b.*, amt_spent*0.5 as points_earned from
(select a.userid, a.product_id,sum(p.price) as amt_spent from
(select s.*, g.gold_signup_date from sales s inner join
goldusers_signup g on s.userid = g.userid and created_date >= gold_signup_date and created_date <= dateadd(year,1,gold_signup_date)) a
inner join product p on a.product_id = p.product_id
group by userid,a.product_id) b


11. Rank all the transactions of the customers

select *, rank() over (partition by userid order by created_date) as rnk from sales;



12.  Rank all the transactions for each member whenever they are gold member and every non gold member transaction mark as NA 

select b.*, case when rnk = 0 then 'NA' else rnk end as rnkk from
(select a.*, cast((case when gold_signup_date is null then 0 else  rank() over (partition by userid order by created_date desc) end) as varchar) as rnk  from
(select s.userid, s.created_date, s.product_id, g.gold_signup_date from sales s
left join goldusers_signup g on s.userid = g.userid and created_date >= gold_signup_date) a) b

