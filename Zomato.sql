create schema zomato;

use zomato;

drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

INSERT INTO goldusers_signup(userid, gold_signup_date)
VALUES (1, '2017-09-22'),
       (3, '2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');


drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 





INSERT INTO sales (userid, created_date, product_id)
VALUES
    (1, '2017-04-19', 2),
    (3, '2019-12-18', 1),
    (2, '2020-07-20', 3),
    (1, '2019-10-23', 2),
    (1, '2018-03-19', 3),
    (3, '2016-12-20', 2),
    (1, '2016-11-09', 1),
    (1, '2016-05-20', 3),
    (2, '2017-09-24', 1),
    (1, '2017-03-11', 2),
    (1, '2016-03-11', 1),
    (3, '2016-11-10', 1),
    (3, '2017-12-07', 2),
    (3, '2016-12-15', 2),
    (2, '2017-11-08', 2),
    (2, '2018-09-10', 3);

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


select price from product
limit 2
rank 2;
-- ...........................................................................................

-- 1. What is the total amount each customer spent on zomato?

select a.userid, sum(b.price) total_amt_spe from sales a
inner join product b on a.product_id = b.product_id
group by a.userid;  


-- 2. How many days each customer visited zomato ?    
  
  select userid , count(distinct created_date) from sales
  group by userid;                                     -- dd 
   
  
  -- 3. What was the first product purchased by each customers?             --   ddd
  
  
  WITH RankedSales AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk
    FROM
        sales
)

SELECT *
FROM
    RankedSales
WHERE
    rnk = 1;
 
 -- or 
 
 select *from  (select *, rank() over(partition by userid order by created_date) rnk from sales)   
 a where rnk = 1
 ;
 
 
 -- 4 What is the most purchased item on the menu and how many times was it purchased by all custmers?   -- dd
 
 -- 1st half most purchased item
    select product_id from sales group by product_id order by count(product_id) desc
    limit 1; 
    
    -- how many time by all customer
 select userid, count(product_id) from sales where product_id = (select product_id from sales group by product_id order by count(product_id) desc
    limit 1) 
    group by userid;
 
-- 5 . Which Item was the most most popular for each customer?   -- dd rank 

select product_id from sale 
group by userid
order by count(userid) desc
limit 1;


 -- 6. Which item was purchased first by the customer after they became a member?
 
 select * from
 (select c.* , rank() over(partition by userid order by created_date) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a
inner join goldusers_signup b on a.userid = b.userid and created_date >= gold_signup_date) c)d where rnk = 1 ;
 
 
 
 -- trial 
 select product_id , price,  rank() over (order by price desc) rnk from product ;
 

-- 7. Which item was purchased first by the customer before they became a member?

select * from
 (select c.* , rank() over(partition by userid order by created_date) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a
inner join goldusers_signup b on a.userid = b.userid and created_date <= gold_signup_date) c)d where rnk = 1 ;
 
 
 -- 8.  What is the total orders and amount spent for each member before they became a member ?
 
 select userid,count(created_date) order_purchased , sum(price) total_amt_spent from 
 (select c.*, d.price from 
(select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join
goldusers_signup b on a.userid = b.userid and created_date <= gold_signup_date)c inner join product d on c.product_id = d.product_id)e
group by userid;
 
 
 
 
 
 --  9. If buying each product generates points for eg 5rs = 2  zomato point and each product has different purchasing points 
 -- for eg for p1 5rs = 1 zomato point, for p2 10rs= 5 z.point and p3 5rs= 1 z.point, calculate points collected by each customers and for which product most points have been given till now?
 
 
 select userid,sum(total_point)*2.5 total_money_earned from
 (select e.*, amt/points  total_point from 
 (select d.*,case when product_id = 1  then 5 when product_id =2 then 2 when product_id = 3 then 5 else 0 end as points from
 (select c.userid, c.product_id,sum(price) amt from
 (select a.*, b.price from sales a inner join product b on a.product_id = b.product_id)c
 group by userid, product_id)d)e)f group by product_id;
 
 
 -- d
 
 -- 10. In the first one year after a customer joins the gold program (including join date) irresoective  of what the 
 -- customer has  purchased they earn 5 zomato points for every 10rs spent who earned more 1 0r 3 and what was their points earning in their first yr ?
 
 -- 1  zp = 2rs                                                                                                                      ---dd 
 -- 0.5 zp 1rs
 
 select c.*, d.price*0.5 total_points_earned from 
 (select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a inner join
 goldusers_signup b on a.userid= b.userid and created_date >= gold_signup_date and created_date <= DATEADD(year, 1, gold_signup_date))c
 inner join product d on c.product_id = d.product_id;
 
 
 -- 11. rnk all the transaction of customers
 
 select *, rank() over(partition by userid order by created_date) rnk from sales;
 
 
 
 -- 12. rank all the transactions for each member whenever they are a zomato gold member 
 -- for every non gold member transaction mark as na 
 
 select e.*,case when rnk=0 then "na" else rnk end as rnkk from 
 (select c.*,cast((case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc) end) as varchar) as rnk from   -- dd varchar
 (select a.userid, a.created_date, a.product_id, b.gold_signup_date from sales a left join
 goldusers_signup b on a.userid= b.userid and created_date >= gold_signup_date)c)e;
 
 
 
 
 
 
 
 
 