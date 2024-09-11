use pppp;
select * from orders;

select * from order_details;

select * from pizza_types;

select * from pizzas;

-- 1.Retrieve the total number of orders placed.
select count(order_details_id) from order_details;

-- 2.Calculate the total revenue generated from pizza sales.
select sum(price) from pizzas;

-- 3.Identify the highest-priced pizza.
select max(price) from pizzas;

-- 4.Identify the most common pizza size ordered.
select size, COUNT(*) as order_count
from pizzas
group by size
order by order_count desc 
limit 1;


-- 5.List the top 5 most ordered pizza types along with their quantities.
select pizza_type_id, count(*) as 
order_count 
from pizza_types
group by pizza_type_id
order by order_count desc
Limit 5;


-- 1.Join the necessary tables to find the total quantity of each pizza category ordered.



SELECT 
    pizza_types.category, 
    SUM(order_details.quantity) AS total_ordered 
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    total_ordered DESC;

    
-- 2. Determine the distribution of orders by hour of the day.
select extract(hour from o.time) as hour_of_day, 
	count(o.order_id) as order_count
from orders o
group by
extract(hour from o.time)
order by				
hour_of_day;

-- 	3.Join relevant tables to find the category-wise distribution of pizzas.
use pppp;
select pt.category, count(od.pizza_id) as pizza_count
from order_details od
join pizzas p on od.pizza_id= p.pizza_id
join pizza_types pt on p.pizza_type_id= pt.pizza_type_id
group by pt.category
order by pizza_count desc;

-- 4..Group the orders by date and calculate the average number of pizzas ordered per day.
USE pppp;

SELECT 
    order_date, 
    AVG(pizza_count_per_day) AS avg_pizzas_per_day 
FROM (
    SELECT 
        DATE(orders.date) AS order_date, 
        COUNT(od.pizza_id) AS pizza_count_per_day
    FROM 
        orders  
    JOIN 
        order_details od ON orders.order_id = od.order_id
    GROUP BY 
        DATE(orders.date)
) AS daily_pizza_counts
GROUP BY 
    order_date
ORDER BY 
    order_date;


-- 5.Determine the top 3 most ordered pizza types based on revenue.
	select pt.name as pizza_type,
	sum(od.quantity * p.price) as total_revenue
	from order_details od 
	join pizzas p on od.pizza_id = p.pizza_id
	join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
	group by pt.name
	order by total_revenue desc
	limit 3;
    
    
-- 1. analyse the cummulative revenue generated over time.
USE pppp;

SELECT 
    sales.date,
    SUM(sales.sold) OVER (ORDER BY sales.date) AS running_total_sales
FROM (
    SELECT 
        orders.date, 
        SUM(p.price * od.quantity) AS sold
    FROM 
        orders 
    JOIN 
        order_details od ON od.order_id = orders.order_id
    JOIN 
        pizzas p ON p.pizza_id = od.pizza_id
    GROUP BY 
        orders.date
) AS sales
ORDER BY 
    sales.date;
    
-- 2.detemine the top 3 most ordered pizza types based on revenue for each pizza category.
USE pppp;

/*SELECT name, revenue
FROM (
    SELECT category, name, revenue, 
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT pizza_types.category, pizza_types.name,
               SUM(order_details.quantity * pizzas.price) AS revenue
        FROM pizza_types
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details ON order_details.pizza_id = pizzas.pizza_type_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS a
) AS b
WHERE rn <= 3;*/

USE pppp;

SELECT pizza_types.category, pizza_types.name,
       SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_type_id = order_details.pizza_type_id
GROUP BY pizza_types.category, pizza_types.name;


-- 3.calculate the percentage contribution of each _pizza type to total revenue.
USE pppp;

WITH TotalRevenue AS (
    SELECT SUM(order_details.quantity * pizzas.price) AS total_revenue
    FROM pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_type_id
),
PizzaRevenue AS (
    SELECT pizza_types.category, pizza_types.name,
           SUM(order_details.quantity * pizzas.price) AS revenue
    FROM pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_type_id
    GROUP BY pizza_types.category, pizza_types.name
)
SELECT pr.category, pr.name, pr.revenue,
       (pr.revenue / tr.total_revenue) * 100 AS percentage_contribution
FROM PizzaRevenue pr, TotalRevenue tr;
