-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
round((sum(order_details.quantity*pizzas.price)/(select ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id))*100,2) as revenue
from pizza_types join pizzas 
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category order by revenue desc;


-- Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name,revenue from 
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as rn
from
 (select pizza_types.category,pizza_types.name,
 sum((order_details.quantity) * pizzas.price) as revenue
 from pizza_types join pizzas
 on pizza_types.pizza_type_id=pizzas.pizza_type_id
 join order_details
 on order_details.pizza_id=pizzas.pizza_id
 group by pizza_types.category,pizza_types.name) as a) as b
 where rn<=3;
 