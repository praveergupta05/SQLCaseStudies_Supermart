select * from customer
select * from products
select * from shipping
select * from sales
select * from targetsales

--Q1 list the top 10 customers by total sales amount. show customerid, full name and total sales

with CTE as (
select customerid,SUM(quantity*price) [totalsales] from sales
group by customerid
) 

select top 10 z.customerid,c.firstname + ' ' + c.lastname [customername],totalsales from CTE z left join customer c 
on z.customerid = c.id
order by totalsales desc

--Q2 Show total sales per month for the year 2023, ordered by month

select datename(month,orderdate) [ordermonthname],SUM(price) [totalsales] from sales
group by month(orderdate),datename(month,orderdate)
order by month(orderdate)


--Q3 find out products that have never been sold

select z.productid,p.productname,p.category from
(select productid from products 
where productid not in (select distinct productid from sales)) z left join products p on z.productid = p.productid


--Q4 find how many new customers were acquired in 2022


select count(distinct customerid) [New_customer_2022] from sales
where customerid not in 
(select distinct customerid from sales
where datename(year,orderdate) <2022) and datename(year,orderdate) = 2022

--Q5 calculate the profit margin (profit/sales) percentage for each category


select p.category,cast(sum(s.profit)/sum(s.price) * 100 as decimal(10,2)) as [%_profit] from sales s left join products p on s.productid = p.productid
group by p.category


--Q6 For each category, show date wise sales and a running total of sales over time

select p.category,s.orderdate,sum(s.price) [TotalSales],SUM(sum(s.price)) over(partition by p.category order by s.orderdate) 
as [CumulativeSales]
from sales s left join products p 
on s.productid = p.productid
group by p.category,s.orderdate
order by p.category,s.orderdate

--Q7 Get the most recent order (by orderdate) for every customer


select distinct t.customerid,s.orderid,s.orderdate from
(select customerid,max(orderdate) as mostrecent from sales
group by customerid) t left join sales s on t.customerid = s.customerid and t.mostrecent = s.orderdate

--Q8. classify customers based on their total sale. Show customerid, name, total sales
--Platinum - >= 15000
--Gold - 10,000 to 15000
--Silver - 5000 to 10000
--Bronze - <5000


select t.customerid,c.firstname + ' ' + c.lastname [FullName],customer_category,TotalSales from
(select customerid,
case
	when SUM(price) >=15000 then 'Platinum'
	when SUM(price) between 10000 and 15000 then 'Gold'
	when SUM(price) between 5000 and 10000 then 'Silver'
	else 'Bronze'
end as [customer_category],sum(price) [TotalSales]
from sales
group by customerid) t left join customer c on t.customerid = c.id

--Q9 For each category, find the product with the highest total sales. if ties exist, show all tied products


with CTE as (
select p.category,p.productname,totalsales,rank() over(partition by p.category order by totalsales desc) [rk] from
(select productid,SUM(price) [TotalSales] from sales
group by productid) t left join products p on t.productid = p.productid
)

select category,productname,totalsales from CTE
where rk = 1

--Q10 Actual vs Target sales by category & year

select * from Sales
select * from targetsales
select * from products

select datename(year,orderdate) [year],category,SUM(price) [TotalSales] from
(select p.category,s.orderdate,s.price from sales s left join products p on s.productid = p.productid) l
group by datename(year,orderdate),category
order by 



With CTE as 
(
select category,replace(year,'_sales','') [Year],targetsales from
(select category,Year,Targetsales from targetsales
unpivot (targetsales for Year in ([2020_sales],[2021_sales],[2022_sales],[2023_sales])) r
) n
)

select Yr,l.category,totalsales,c.targetsales from
(select datename(year,orderdate) [Yr],p.category,SUM(s.price) [totalsales] from sales s left join products p 
on s.productid = p.productid
group by datename(year,orderdate),category) l left join CTE c on l.yr = c.year and l.category = c.category
order by Yr,l.category










