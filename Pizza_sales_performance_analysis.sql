CREATE DATABASE PIZZAHUT;
use PIZZAHUT;
CREATE TABLE Orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id)
);

CREATE TABLE Orders_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id)
)

/* -------Retrieve the total number of orders placed. ----------*/

SELECT 
    COUNT(order_id) AS Total_number_of_orders
FROM
    orders;
    
/* -----------Calculate the total revenue generated from pizza sales.------------ */

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;
    
/*---------- Identify the highest-priced pizza.-------------------- */

SELECT 
    pizza_types.name, pizzas.price AS highest_priced_pizza
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

/* --------Identify the most common pizza size ordered.------------ */

SELECT 
    pizzas.size, SUM(orders_details.quantity) as Times_orderded
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size order by Times_orderded desc limit 1;

/*------ List the top 5 most ordered pizza types along with their quantities.---------- */

SELECT 
    pizza_types.name, SUM(orders_details.quantity) as total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;

/* -----------Join the necessary tables to find the total quantity of each pizza category ordered.-------*/

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
        JOIN
    orders ON orders_details.order_id = orders.order_id
GROUP BY pizza_types.category;

/* -------------Determine the distribution of orders by hour of the day.---------------*/

SELECT 
    HOUR(orders.order_time) AS hour,
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour
order by hour;

/*--------- Join relevant tables to find the category-wise distribution of pizzas.------- */

SELECT 
    category, name
FROM
    pizza_types
GROUP BY category;

/*--------- Group the orders by date and calculate the average number of pizzas ordered per day.------*/

SELECT 
    ROUND(AVG(quantity)) AS avg_pizzas_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

/*----- Determine the top 3 most ordered pizza types based on revenue.------------*/

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

/*-------- Calculate the percentage contribution of each pizza type to total revenue.-------- */

SELECT 
    pizza_types.category,
    ROUND((SUM(orders_details.quantity * pizzas.price) * 100 / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price),
                                2) AS total_revenue_generated
                FROM
                    orders_details
                        JOIN
                    pizzas ON orders_details.pizza_id = pizzas.pizza_id)),
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

/* ---------Analyze the cumulative revenue generated over time.--------*/

select order_date, round(sum(revenue) over(order by order_date),2)as cumulative_revenue 
from (select orders.order_date , round(sum(pizzas.price * orders_details.quantity),2) as revenue 
from 
orders_details join orders 
on orders_details.order_id =orders.order_id 
join
pizzas
on pizzas.pizza_id =orders_details.pizza_id group by orders.order_date ) as sales;

/*------ Determine the top 3 most ordered pizza types based on revenue for each pizza category.---------*/

select name, revenue,rn from 
(select category,name, revenue, rank() over (partition by category 
order by revenue desc)as rn from 
(select pizza_types.category,pizza_types.name,
round(sum(orders_details.quantity*pizzas.price),2)as revenue 
from pizza_types join pizzas
on pizza_types.pizza_type_id =pizzas.pizza_type_id
join orders_details
on pizzas.pizza_id=orders_details.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b where rn<4;

