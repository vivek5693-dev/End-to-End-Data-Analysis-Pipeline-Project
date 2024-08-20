
'''
create table df_orders (
    [order_id] int primary key
    ,[order_date] date
    ,[ship_mode] varchar(20)
    ,[segment] varchar(20)
    ,[country] varchar(20)
    ,[city] varchar(20)
    ,[state] varchar(20)
    ,[postal_code] varchar(20)
    ,[region] varchar(20)
    ,[category] varchar(20)
    ,[sub_category] varchar(20)
    ,[product_id] varchar(50)
    ,[quantity] int
    ,[discount] decimal(7,2)
    ,[sale_price] decimal(7,2)
    ,[profit] decimal(7,2)
)
'''

-- select * from dbo.df_orders;

-- 1 .Find top 10 highest reveue generating products
select top 10 product_id  , sum(sale_price) as sales 
from df_orders
group by product_id
order by sales desc ;

-- 2.Find top 5 highest selling products in each region

with cte as (
select region , product_id , sum(sale_price) as sales ,
ROW_NUMBER() over (partition by region order by SUM(sale_price) desc ) as sales_rank 
from df_orders 
group by region , product_id
)
select *    
from cte
where sales_rank <= 5  ;

-- 3.Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
-- select distinct(category)  from df_orders ;

with cte as (
select year(order_date) as order_year , month(order_date) as order_month , sum(sale_price) as sales 
from df_orders
group by year(order_date) , month(order_date)
)
select order_month ,
sum(case when order_year = 2022 then sales else 0  end ) as sales_2022,
sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte 
group by order_month 
order by order_month  desc ;

-- 4.For each category which month had highest sales 
with cte as (
select  category , format(order_date , 'yyyyMM') as order_year_month , 
sum(sale_price) as sales 
from df_orders 
group by category , format(order_date , 'yyyyMM')
)
select * from (
select * ,
row_number() over(partition by category order by sales desc) as sales_rank
from cte
) A
where sales_rank =1 
order by sales desc ;


--5.Which sub category had highest growth by profit in 2023 compare to 2022
with cte1 as (
select sub_category , year(order_date) as order_year , sum(sale_price) as sales 
from df_orders 
group by sub_category , year(order_date)
),
cte2 as (
select sub_category , 
sum(case when order_year = 2022 then sales else 0  end )as sale_2022
,sum(case when order_year = 2023 then sales else 0 end) as sale_2023
from cte1 
group by sub_category 
)
select top 1 * , (sale_2022 - sale_2022) * 100 / sale_2022
from cte2
order by  (sale_2022 - sale_2022) * 100 / sale_2022 ;