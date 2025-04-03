select * from Orders_Data
------------------------------------------------------
--top 10 products in revenue
select top 10 product_id , sum(sale_price) as Revenue
from orders_data
group by product_id
order by Revenue desc
------------------------------------------------------
--top 5 products Revenue for every region
with CTE as
(select region, product_id, sum(sale_price) as Revenue
from Orders_Data
group by region, product_id
) 
	select * from (
		select * ,
		ROW_NUMBER() over (partition by region order by Revenue desc) as rn
		from CTE) A
	where rn <= 5
------------------------------------------------------
--month over month Revenue comparison from 2022 and 2023
with CTE as
(select year(order_date) as year_order, month(order_date) as month_order, sum(sale_price) as Revenue
from Orders_Data 
group by year(order_date), month(order_date)
--order by year(order_date), month(order_date)
)
	select month_order,
	sum(case when year_order = 2022 then Revenue else 0 end) as Revenue_2022,
	sum(case when year_order = 2023 then Revenue else 0 end) as Revenue_2023
	from CTE
	group by month_order
	order by month_order
------------------------------------------------------
--the highest Revenue for every category at every month for every year
with CTE as 
(select category, year(order_date) as year_order, month(order_date) as month_order , sum(sale_price) as Revenue
from Orders_Data
group by category, year(order_date), month(order_date) 
)
	select * from
	(
		select *, ROW_NUMBER () over (partition by category,year_order order by Revenue desc) as rn
		from CTE
	) A
	where rn = 1
------------------------------------------------------
--which sub-category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from Orders_Data
group by sub_category,year(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select *
,(sales_2023-sales_2022)*100/sales_2022 as Growth_percentage
from  cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc
