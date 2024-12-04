/* ---Retrieve the total number of orders placed.-------*/

select count(order_id) from orders;

/***Calculate the total revenue generated from pizza sales.**/

select round(sum(pizzas.price *orders_details.quantity),2) as total_revenue from 
pizzas join orders_details
on pizzas.pizza_id = orders_details.pizza_id;

/*Identify the highest-priced pizza.*/

select pizza_types.name from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id where pizzas.price=(select max(price) from pizzas);

/*Identify the most common pizza size ordered.**********/

select pizzas.size, sum(orders_details.quantity) as number_of_times_ordered from 
pizzas join orders_details
on pizzas.pizza_id =orders_details.pizza_id
group by pizzas.size order by number_of_times_ordered desc limit 1;

/* List the top 5 most ordered pizza types along with their quantities. */

select pizza_types.name , sum(orders_details.quantity)as total_count from 
pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details
on pizzas.pizza_id=orders_details.pizza_id
group by pizza_types.name  order by total_count desc limit 5;

/** Join the necessary tables to find the total quantity of each pizza category ordered.**/

select pizza_types.category,sum(orders_details.quantity) as total_count from  pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details
on pizzas.pizza_id=orders_details.pizza_id
group by pizza_types.category  order by total_count ;

/**Determine the distribution of orders by hour of the day.**/

select hour(order_time), count(order_id) from orders group by hour(order_time);

/*******Join relevant tables to find the category-wise distribution of pizzas.*****/

select category, count(name) from pizza_types group by category;

/******Group the orders by date and calculate the average number of pizzas ordered per day.*********/

select round(avg(quantity),0) from (select orders.order_date, sum(orders_details.quantity)as quantity from orders join orders_details
on orders.order_id=orders_details.order_id
group by orders.order_date) as a ;

/**Determine the top 3 most ordered pizza types based on revenue.**/

select pizza_types.name,sum(orders_details.quantity*pizzas.price) as revenue from 
pizzas join orders_details
on pizzas.pizza_id=orders_details.pizza_id
join pizza_types
on pizza_types.pizza_type_id=pizzas.pizza_type_id
group by pizza_types.name order by revenue desc limit 3;

/**Calculate the percentage contribution of each pizza type to total revenue.**/

select category, round((revenue *100 / (select sum(pizzas.price * orders_details.quantity) from pizzas join orders_details
on pizzas.pizza_id =orders_details.pizza_id )),2) as percent from 
(select pizza_types.category, round(sum(orders_details.quantity*pizzas.price),2)as revenue 
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id group by pizza_types.category) as a;

/** Analyze the cumulative revenue generated over time.**/

select order_date, round(sum(revenue) over(order by order_date ),2)from (select orders.order_date,sum(orders_details.quantity*pizzas.price)as revenue from orders join orders_details
on orders.order_id=orders_details.order_id
join pizzas
on orders_details.pizza_id=pizzas.pizza_id
group by orders.order_date) as a;

/**Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/
select category, name ,rn from (select category, name , revenue , rank() over (partition by category order by revenue desc ) as rn from (select pizza_types.category,pizza_types.name, round(sum(orders_details.quantity *pizzas.price),2)as revenue from 
pizzas join pizza_types
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join orders_details
on pizzas.pizza_id=orders_details.pizza_id
group by pizza_types.category , pizza_types.name ) as a) as b where rn<=3;
