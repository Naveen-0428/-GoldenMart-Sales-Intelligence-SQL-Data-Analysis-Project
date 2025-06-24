--date wise total sales 
select order_date , sum(sales_amount) as total_sales
from gold_fact_sales
where order_date is not null
group by order_date
order by order_date            

--month wise total sales , format(order_date,'yyyy-mm-dd') or datetrunc function can be used also for the date extraction
SELECT MONTH(order_date) AS month ,year(order_date)as year,sum(sales_amount) as total_sales,count(distinct customer_key) as total_customers,sum(quantity) as total_quantity
from gold_fact_sales 
where order_date is not null
group by year(order_date),MONTH(order_date)
order by year(order_date),MONTH(order_date)

--year wise total_sales and total_customers
SELECT year(order_date) AS year ,sum(sales_amount) as total_sales , count(distinct customer_key) as total_customers,sum(quantity) as total_quantity
from gold_fact_sales 
where order_date is not null
group by year(order_date)
order by year(order_date)


--cumalative analysis of data  on sales , if we suppy only order by then it do for all years , using partition by means year wise partition 
select order_date,
total_sales ,
sum(total_sales) over ( partition by order_date order by order_date) as running_total_sales
from (
select sum(sales_amount) as total_sales , Datetrunc(month,order_date)  as order_date
from gold_fact_sales 
where order_date is not null
group by Datetrunc(month,order_date)
) t

--MOVING AVERAGE OF COMPANY
select order_date,
total_sales ,
avg(avg_price) over ( order by order_date) as moving_average_price
from (
select sum(sales_amount) as total_sales , Datetrunc(year,order_date)  as order_date,AVG(price) as avg_price
from gold_fact_sales 
where order_date is not null
group by Datetrunc(year,order_date)
) t

--performance analysis .... comaparing current value to target value .... current()-target()
--analyze yearly performance of product  by comparing sales to both average sales performance of the product and previous year sales 
  --sales and average sales comparsion based on product 
with yearly_product_sales as (
select gp.product_name,year(gf.order_date) as order_year,sum(gf.sales_amount) as total_sales 
from gold_fact_sales as gf 
left join gold_dim_products as gp
on gf.product_key = gp.product_key
where year(gf.order_date) is not null
group by gp.product_name,year(gf.order_date)
)
select order_year,product_name,total_sales ,avg(total_sales) over (partition by  product_name) as average_sales,
(total_sales - avg(total_sales) over (partition by  product_name)) as difference_sales,
case when total_sales -avg(total_sales) over (partition by  product_name)> 0 then 'above average'
     when total_sales - avg(total_sales) over (partition by  product_name)<0 then 'below_average'
else 'average' end as average_change 
from yearly_product_sales 
order by product_name , order_year

--comparision of current year sales to previous year sales product wise 
with yearly_product_sales as (
select gp.product_name,year(gf.order_date) as order_year,sum(gf.sales_amount) as total_sales 
from gold_fact_sales as gf 
left join gold_dim_products as gp
on gf.product_key = gp.product_key
where year(gf.order_date) is not null
group by gp.product_name,year(gf.order_date)
)
select order_year,product_name,total_sales ,avg(total_sales) over (partition by  product_name) as average_sales,
(total_sales - avg(total_sales) over (partition by  product_name)) as difference_sales,
case when total_sales -avg(total_sales) over (partition by  product_name)>0 then 'Above_average'
     when total_sales - avg(total_sales) over (partition by  product_name)<0 then 'below_average'
else 'average' end as average_change,
lag(total_sales) OVER (PARTITION BY product_name order by order_year asc  ) as prev_year_sales ,
total_sales -lag(total_sales) OVER (PARTITION BY product_name order by order_year asc  ) as yearly_comparision,
CASE when total_sales - lag(total_sales) OVER (PARTITION BY product_name order by order_year )>0 then'good growth'
     when total_sales - lag(total_sales) OVER (PARTITION BY product_name order by order_year)<0 then 'decline growth'
else 'stable' end as company_status
from yearly_product_sales 
order by product_name , order_year

--analyze how a individual part is performing compared to the overall
--which category contribute the most to overall sale
with category_sales as (
select gp.category  , sum(gf.sales_amount)  as total_sales                      
from gold_fact_sales as gf 
left join gold_dim_products as gp
on gf.product_key = gp.product_key
group by gp.category) 

select category, total_sales,sum(total_sales) over() as overall_sales , concat(round(cast(total_sales  as float)*100/sum(total_sales) over() ,2),'%') category_contribution
from category_sales 
order by total_sales desc 

--data segmentation= group data based on a specific range
--segments products into cost ranges and count products in each segment 
with product_status1 as(
select product_name   ,case when cost >=1500 then 'highly Expensive product'
            when cost<1500 and cost>=1000 then 'expensive product'
			when cost<1000 and cost>=500 then 'affordable product'
else 'cheap product' end as product_status
from gold_dim_products)

select count(product_name) as product_quantity , product_status from product_status1
group by product_status 

-- group customers into three segments based on their spending behaviour
with lifespan as (
select gc.customer_key,sum(gf.sales_amount) as total_sales,min(order_date) as first_order , max(order_date) as last_order ,datediff(month,min(order_date),max(order_date)) as lifespan
from gold_fact_sales as gf
left join gold_dim_customers as gc
on gf.customer_key = gc.customer_key
group by gc.customer_key
)

select 
customer_status, count(customer_key) as total_customer
from
(select 
 case
      when total_sales>5000 and lifespan >= 12 then 'VIP customers'
      when total_sales<=5000 and lifespan>=12 then 'regular customers'
else 'beginner customer ' end as customer_status 
,customer_key
from lifespan
) n
Group By customer_status
order by total_customer asc


--visualosation of the important data for report 
create view gold_report_customers as
--base
with base_data as(
select  gf.order_number , gf.product_key,gf.order_date,gf.sales_amount,gf.quantity, gc.customer_key,gc.customer_number,
concat(gc.first_name,' ', gc.last_name) as customer_name, datediff(year,gc.birthdate,getdate()) as age
from gold_fact_sales as gf 
left join gold_dim_customers as gc 
on gf.customer_key = gc.customer_key
where order_date is not null)

--agregation 
, customer_aggregation as (
select customer_key,customer_number, age,
count(distinct order_number) as  total_orders ,
sum(sales_amount) as total_sales,sum(quantity) as total_quantity,count(distinct product_key) as total_products,max(order_date) as last_orderdate,
datediff(month,min(order_date),max(order_date)) as lifespan
from base_data
group by customer_key , customer_number,age 
)
select  customer_key,customer_number, age, total_orders ,
 total_sales, total_quantity,total_products ,last_orderdate,lifespan,
  case
      when total_sales>5000 and lifespan >= 12 then 'VIP customers'
      when total_sales<=5000 and lifespan>=12 then 'regular customers'
else 'beginner customer ' end as customer_status ,datediff(month , last_orderdate,getdate()) as recency,
case when total_orders =0 then 0 
else ( total_sales/ total_orders) end as average_order_vl,
case when age<20 then 'under 20'
     when age between 20 and 29 then '20-29'
	 when age between 30 and 39 then '30-39'
	 when age between 40 and 49 then '40-49'
else '50--50+' end as age_group,
case when lifespan=0 then total_sales
else total_sales/lifespan end as monthly_average_spend_vl
 from customer_aggregation

