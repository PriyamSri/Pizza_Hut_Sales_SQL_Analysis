Create Database Pizzahut;
use Pizzahut;

Create Table orders
 (order_id int not null primary key, 
 order_date date not null, 
 order_time time not null);
 
 Create Table order_details
 (order_details_id int not null primary key,
 order_id int not null, 
 pizza_id text not null,
 quantity int not null);
 
--- Importing Done ---

--- BASIC ANALYSIS ---

-- Q1. Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;


-- Q2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_Revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


-- Q3. Identify the highest-priced pizza.

SELECT 
    price AS Highest_Price
FROM
    pizzas
ORDER BY price DESC
LIMIT 1;


-- Q4. Identify the most common pizza size ordered.

SELECT 
    size,
    COUNT(order_details.order_details_id) AS Number_of_Orders
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY Size
ORDER BY Number_of_Orders DESC;


-- Q5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name AS Pizza_Type,
    SUM(order_details.quantity) AS Quantity_Ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY COUNT(order_details_id) DESC
LIMIT 5;


--- INTERMEDIATE ANALYSIS ---

-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category AS Pizza_Category,
    SUM(order_details.quantity) AS Quantity_Ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;


-- Q7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time) ASC;


-- Q8. Join relevant tables to find the category-wise order distribution of pizzas.

SELECT 
    pizza_types.category AS Pizza_Category,
    COUNT(order_details.order_id) AS Number_Of_Orders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY COUNT(order_details.order_id) DESC;


-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(Average_Order), 0)
FROM
    (SELECT 
        order_date AS date_of_order,
            SUM(order_details.quantity) AS Average_Order
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS order_quant;


-- Q10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name AS Pizza_Type,
    SUM(order_details.quantity * pizzas.price) AS Total_Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY SUM(order_details.quantity * pizzas.price) DESC
LIMIT 3;



--- ADVANCE ANALYSIS ---


-- Q11. Calculate the percentage contribution of each pizza type to total revenue.

	select pizza_types.category, round((sum(order_details.quantity*pizzas.price) / (SELECT 
		ROUND(SUM(order_details.quantity * pizzas.price),
				2) AS Total_Revenue
	FROM
		order_details
			JOIN
		pizzas ON order_details.pizza_id = pizzas.pizza_id)*100),2) AS revenue
	FROM pizza_types
	JOIN pizzas On pizza_types.pizza_type_id = pizzas.pizza_type_id 
	JOin order_details on pizzas.pizza_id = order_details.pizza_id
	Group by pizza_types.category order by revenue desc;
    
    
--     Q12. Analyze the cumulative revenue generated over time.

select order_date, sum(Total_Revenue) over (Order by order_date) FROM
(SELECT orders.order_date, 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_Revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders on order_details.order_id = orders.order_id
    group by orders.order_date) as sales;
    
    
-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, category, revenue 
FROM
(SELECT category, name, revenue,
RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS ranking 
FROM
(SELECT pizza_types.category, pizza_types.name, SUM((order_details.quantity) * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category, pizza_types.name) 
AS a) AS b
WHERE ranking <=3;