drop table df_orders;
-- create the table with appropriate constraint
create table df_orders(
	order_id int primary key,
    order_date date,
    ship_mode varchar(20),
    segment varchar(20),
    country varchar(20),
    city varchar(20),
    state varchar(20),
    postal_code varchar(20),
    region varchar(20),
    category varchar(20),
	sub_category varchar(20),
    product_id varchar(50),
    quantity int,
    discount decimal(7,2),
    sale_price decimal(7,2),
    profit decimal(7,2)
);
-- Q1. Find top 10 heighest revenue generating product
select sub_category as products,sum(quantity*sale_price) as revenue
from df_orders
group by products
order by revenue desc limit 10;

-- Find top 5 heighest selling products in each region
select *
from 
(select *,rank()
over(partition by region order by quantity desc) as RN
from
(select region,sub_category as products,count(quantity) as quantity
from df_orders
group by region,products
order by region,products) as a) as b
where RN<=3;

-- find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023

with cte as 
(select month,year,sales from(select * , rank()
over(partition by month order by year)
from (select month(order_date) as month, year(order_date) as year,sum(quantity*sale_price) as sales
from df_orders
group by month,year) as a) as b)
select month,sum(case when year=2022 then sales else 0 end) as 2022_sales,
sum(case when year=2023 then sales else 0 end) as 2023_sales
from cte
group by month;

-- Q4.for each category which month had heighest sales
select * from (select *, rank()
over(partition by category order by sales desc) as RN
from (select category,date_format(order_date,"%Y %M") as order_date,sum(quantity*sale_price) as sales
from df_orders
group by category,order_date) as a)as b
where RN=1;

-- Q5.which sub_category had highest growth by profit in 2023 compare to 2022

select *,(year_2022-year_2023) as growth, (year_2022-year_2023)*100/(year_2023) as growth_percent
from (with cte as (select sub_category,sum(profit*quantity) as profit,year(order_date) as year
from df_orders
group by sub_category,year)
select sub_category,
sum(case when year=2022 then profit else 0 end) as year_2022,
sum(case when year=2023 then profit else 0 end) as year_2023
from cte 
group by sub_category) as a
order by growth desc;

