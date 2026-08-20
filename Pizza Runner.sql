--A. Pizza Metrics

--cleaning customer_orders table
SELECT order_id,
customer_id,
pizza_id,
CASE
WHEN exclusions = 'null' or exclusions = '' THEN NULL
ELSE exclusions
END AS exclusions,
CASE
WHEN extras = 'null' or extras = '' THEN NULL
ELSE extras
END AS extras,
order_time
FROM customer_orders;

--cleaning runners_order table
SELECT order_id,
runner_id,
pickup_time,
CAST(TRIM(REPLACE (distance , 'km', '')) AS REAL) AS distance,
CAST(TRIM(REPLACE(REPLACE(REPLACE (duration, 'minutes', ''),'minute', ''),'mins', '')) AS REAL) AS duration,
CASE
WHEN cancellation = 'null' OR cancellation = '' THEN NULL
ELSE cancellation
END AS cancellation
FROM runner_orders;

--Q1How many pizzas were ordered?
WITH customer_orders_clean AS (
  SELECT order_id,
customer_id,
pizza_id,
CASE
WHEN exclusions = 'null' or exclusions = '' THEN NULL
ELSE exclusions
END AS exclusions,
CASE
WHEN extras = 'null' or extras = '' THEN NULL
ELSE extras
END AS extras,
order_time
FROM customer_orders),
runner_orders_clean AS (
  SELECT order_id,
runner_id,
pickup_time,
CAST(TRIM(REPLACE (distance , 'km', '')) AS REAL) AS distance,
CAST(TRIM(REPLACE(REPLACE(REPLACE (duration, 'minutes', ''),'minute', ''),'mins', '')) AS REAL) AS duration,
CASE
WHEN cancellation = 'null' OR cancellation = '' THEN NULL
ELSE cancellation
END AS cancellation
FROM runner_orders)

SELECT COUNT(pizza_id) AS number_pizza_ordered FROM customer_orders_clean;

--Q2How many unique customer orders were made?
WITH customer_orders_clean AS (
  SELECT order_id,
customer_id,
pizza_id,
CASE
WHEN exclusions = 'null' or exclusions = '' THEN NULL
ELSE exclusions
END AS exclusions,
CASE
WHEN extras = 'null' or extras = '' THEN NULL
ELSE extras
END AS extras,
order_time
FROM customer_orders),
runner_orders_clean AS (
  SELECT order_id,
runner_id,
pickup_time,
CAST(TRIM(REPLACE (distance , 'km', '')) AS REAL) AS distance,
CAST(TRIM(REPLACE(REPLACE(REPLACE (duration, 'minutes', ''),'minute', ''),'mins', '')) AS REAL) AS duration,
CASE
WHEN cancellation = 'null' OR cancellation = '' THEN NULL
ELSE cancellation
END AS cancellation
FROM runner_orders)

SELECT COUNT( DISTINCT order_id) AS unique_orders FROM customer_orders_clean;


--Q3How many successful orders were delivered by each runner?

WITH customer_orders_clean AS (
  SELECT order_id,
customer_id,
pizza_id,
CASE
WHEN exclusions = 'null' or exclusions = '' THEN NULL
ELSE exclusions
END AS exclusions,
CASE
WHEN extras = 'null' or extras = '' THEN NULL
ELSE extras
END AS extras,
order_time
FROM customer_orders),
runner_orders_clean AS (
  SELECT order_id,
runner_id,
pickup_time,
CAST(TRIM(REPLACE (distance , 'km', '')) AS REAL) AS distance,
CAST(TRIM(REPLACE(REPLACE(REPLACE (duration, 'minutes', ''),'minute', ''),'mins', '')) AS REAL) AS duration,
CASE
WHEN cancellation = 'null' OR cancellation = '' THEN NULL
ELSE cancellation
END AS cancellation
FROM runner_orders)

SELECT COUNT(*) AS succesful_delivery FROM runner_orders_clean
WHERE cancellation IS NULL
GROUP BY runner_id;

--Q4How many of each type of pizza was delivered?
WITH customer_orders_clean AS (
  SELECT order_id,
customer_id,
pizza_id,
CASE
WHEN exclusions = 'null' or exclusions = '' THEN NULL
ELSE exclusions
END AS exclusions,
CASE
WHEN extras = 'null' or extras = '' THEN NULL
ELSE extras
END AS extras,
order_time
FROM customer_orders),
runner_orders_clean AS (
  SELECT order_id,
runner_id,
pickup_time,
CAST(TRIM(REPLACE (distance , 'km', '')) AS REAL) AS distance,
CAST(TRIM(REPLACE(REPLACE(REPLACE (duration, 'minutes', ''),'minute', ''),'mins', '')) AS REAL) AS duration,
CASE
WHEN cancellation = 'null' OR cancellation = '' THEN NULL
ELSE cancellation
END AS cancellation
FROM runner_orders)

SELECT pizza_names.pizza_id, pizza_name, COUNT(*) AS how_many_of_each_type_of_pizza FROM customer_orders_clean
JOIN pizza_names ON pizza_names.pizza_id = customer_orders_clean.pizza_id
JOIN runner_orders_clean ON runner_orders_clean.order_id = customer_orders_clean.order_id
WHERE cancellation IS NULL
GROUP BY customer_orders_clean.pizza_id;


--Q5How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_orders_clean.customer_id, pizza_name, COUNT(*) AS how_many_of_each_type_of_pizza FROM customer_orders_clean
JOIN pizza_names ON pizza_names.pizza_id = customer_orders_clean.pizza_id
GROUP BY customer_orders_clean.customer_id, pizza_name;

--Q6What was the maximum number of pizzas delivered in a single order?
order_sizes AS (
  SELECT order_id, COUNT(*) AS pizza_count
  FROM customer_orders_clean
  GROUP BY order_id
)
SELECT MAX(pizza_count) AS max_pizzas_in_order
FROM order_sizes;

--Q7For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH customer_orders_clean AS (
  SELECT order_id,
customer_id,
pizza_id,
CASE
WHEN exclusions = 'null' or exclusions = '' THEN NULL
ELSE exclusions
END AS exclusions,
CASE
WHEN extras = 'null' or extras = '' THEN NULL
ELSE extras
END AS extras,
order_time
FROM customer_orders),
runner_orders_clean AS (
  SELECT order_id,
runner_id,
pickup_time,
CAST(TRIM(REPLACE (distance , 'km', '')) AS REAL) AS distance,
CAST(TRIM(REPLACE(REPLACE(REPLACE (duration, 'minutes', ''),'minute', ''),'mins', '')) AS REAL) AS duration,
CASE
WHEN cancellation = 'null' OR cancellation = '' THEN NULL
ELSE cancellation
END AS cancellation
FROM runner_orders)
SELECT
  customer_orders_clean.customer_id,
  SUM(CASE WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 ELSE 0 END) AS with_changes,
  SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 ELSE 0 END) AS no_changes
FROM customer_orders_clean
JOIN runner_orders_clean
  ON customer_orders_clean.order_id = runner_orders_clean.order_id
WHERE runner_orders_clean.cancellation IS NULL
GROUP BY customer_orders_clean.customer_id;

--Q8How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*) AS both_exclusions_and_extras
FROM customer_orders_clean
JOIN runner_orders_clean
  ON customer_orders_clean.order_id = runner_orders_clean.order_id
WHERE runner_orders_clean.cancellation IS NULL
  AND customer_orders_clean.exclusions IS NOT NULL
  AND customer_orders_clean.extras IS NOT NULL;

--Q9What was the total volume of pizzas ordered for each hour of the day?
SELECT
  STRFTIME('%H', order_time) AS hour_of_day,
  COUNT(*) AS pizzas_ordered
FROM customer_orders_clean
GROUP BY STRFTIME('%H', order_time)
ORDER BY hour_of_day;

--Q10What was the volume of orders for each day of the week?
SELECT
  CASE STRFTIME('%w', order_time)
    WHEN '0' THEN 'Sunday'
    WHEN '1' THEN 'Monday'
    WHEN '2' THEN 'Tuesday'
    WHEN '3' THEN 'Wednesday'
    WHEN '4' THEN 'Thursday'
    WHEN '5' THEN 'Friday'
    WHEN '6' THEN 'Saturday'
  END AS day_of_week,
  COUNT(*) AS pizzas_ordered
FROM customer_orders_clean
GROUP BY STRFTIME('%w', order_time)
ORDER BY STRFTIME('%w', order_time);


--B. Runner and Customer Experience
--Q1How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT
  CAST((JULIANDAY(registration_date) - JULIANDAY('2021-01-01')) / 7 AS INTEGER) AS week_number,
  COUNT(*) AS runners_signed_up
FROM runners
GROUP BY CAST((JULIANDAY(registration_date) - JULIANDAY('2021-01-01')) / 7 AS INTEGER)
ORDER BY week_number;

--Q2What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
  runner_orders_clean.runner_id,
  AVG((JULIANDAY(runner_orders_clean.pickup_time) - JULIANDAY(customer_orders.order_time)) * 1440) AS avg_pickup_minutes
FROM runner_orders_clean
JOIN customer_orders
  ON runner_orders_clean.order_id = customer_orders.order_id
WHERE runner_orders_clean.cancellation IS NULL
GROUP BY runner_orders_clean.runner_id;

--Q3Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT
  customer_orders.order_id,
  COUNT(customer_orders.pizza_id) AS pizza_count,
  (JULIANDAY(runner_orders_clean.pickup_time) - JULIANDAY(customer_orders.order_time)) * 1440 AS prep_minutes
FROM customer_orders
JOIN runner_orders_clean
  ON customer_orders.order_id = runner_orders_clean.order_id
WHERE runner_orders_clean.cancellation IS NULL
GROUP BY customer_orders.order_id, runner_orders_clean.pickup_time, customer_orders.order_time;

--Q4What was the average distance travelled for each customer?
WITH order_distances AS (
  SELECT DISTINCT
    customer_orders_clean.customer_id,
    runner_orders_clean.order_id,
    runner_orders_clean.distance
  FROM customer_orders_clean
  JOIN runner_orders_clean
    ON customer_orders_clean.order_id = runner_orders_clean.order_id
  WHERE runner_orders_clean.cancellation IS NULL
)
SELECT
  customer_id,
  AVG(distance) AS average_distance
FROM order_distances
GROUP BY customer_id;

--Q5What was the difference between the longest and shortest delivery times for all orders?
SELECT
  MAX(duration) - MIN(duration) AS delivery_time_difference
FROM runner_orders_clean
WHERE cancellation IS NULL;

--Q6What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
  runner_id,
  order_id,
  distance,
  duration,
  distance / duration * 60 AS speed_kmh
FROM runner_orders_clean
WHERE cancellation IS NULL
ORDER BY runner_id;
--speeds vary a lot between deliveries; runner 1 is steady while runner 2 swings from slow to implausibly fast (order 8 at ~94 km/h), which is an outlier worth questioning rather than taking at face value.

--Q7What is the successful delivery percentage for each runner?
WITH counts AS (
  SELECT
    runner_id,
    SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END) AS successful,
    COUNT(*) AS total
  FROM runner_orders_clean
  GROUP BY runner_id
)
SELECT
  runner_id,
  successful * 100.0 / total AS success_pct
FROM counts;

--OR without using a CTE

SELECT
  SUM(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END) AS successful,
  COUNT(*) AS total,
  successful * 100.0 / total AS success_pct   -- ✗ won't work
FROM runner_orders_clean
GROUP BY runner_id;

--C.Ingredient optimization
--Q1What are the standard ingredients for each pizza?
WITH RECURSIVE split_toppings AS (
  -- Anchor: start each pizza with its full topping list
  SELECT
    pizza_id,
    '' AS topping_id,
    toppings || ',' AS remaining
  FROM pizza_recipes

  UNION ALL

  -- Recursive: peel one topping id off the front of 'remaining'
  SELECT
    pizza_id,
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1)) AS topping_id,
    SUBSTR(remaining, INSTR(remaining, ',') + 1) AS remaining
  FROM split_toppings
  WHERE remaining != ''
)
SELECT
  split_toppings.pizza_id,
  pizza_names.pizza_name,
  GROUP_CONCAT(pizza_toppings.topping_name, ', ') AS standard_ingredients
FROM split_toppings
JOIN pizza_toppings ON CAST(split_toppings.topping_id AS INTEGER) = pizza_toppings.topping_id
JOIN pizza_names ON split_toppings.pizza_id = pizza_names.pizza_id
WHERE split_toppings.topping_id != ''
GROUP BY split_toppings.pizza_id, pizza_names.pizza_name;

--Q2What was the most commonly added extra?
WITH RECURSIVE split_extras AS (
  SELECT
    order_id,
    '' AS topping_id,
    CASE WHEN extras = 'null' OR extras = '' THEN NULL ELSE extras END || ',' AS remaining
  FROM customer_orders
  WHERE extras IS NOT NULL AND extras != 'null' AND extras != ''

  UNION ALL

  SELECT
    order_id,
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1)),
    SUBSTR(remaining, INSTR(remaining, ',') + 1)
  FROM split_extras
  WHERE remaining != ''
)
SELECT
  pizza_toppings.topping_name,
  COUNT(*) AS times_added
FROM split_extras
JOIN pizza_toppings
  ON CAST(split_extras.topping_id AS INTEGER) = pizza_toppings.topping_id
WHERE split_extras.topping_id != ''
GROUP BY pizza_toppings.topping_name
ORDER BY times_added DESC
LIMIT 1;

--Q3What was the most common exclusion?
WITH RECURSIVE split_exclusions AS (
  SELECT
    order_id,
    '' AS topping_id,
    CASE WHEN exclusions = 'null' OR exclusions = '' THEN NULL ELSE exclusions END || ',' AS remaining
  FROM customer_orders
  WHERE exclusions IS NOT NULL AND exclusions != 'null' AND exclusions != ''

  UNION ALL

  SELECT
    order_id,
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1)),
    SUBSTR(remaining, INSTR(remaining, ',') + 1)
  FROM split_exclusions
  WHERE remaining != ''
)
SELECT
  pizza_toppings.topping_name,
  COUNT(*) AS times_excluded
FROM split_exclusions
JOIN pizza_toppings
  ON CAST(split_exclusions.topping_id AS INTEGER) = pizza_toppings.topping_id
WHERE split_exclusions.topping_id != ''
GROUP BY pizza_toppings.topping_name
ORDER BY times_excluded DESC
LIMIT 1;

--if there is a tie (use dense rank)

WITH RECURSIVE split_exclusions AS (
  SELECT
    order_id,
    '' AS topping_id,
    CASE WHEN exclusions = 'null' OR exclusions = '' THEN NULL ELSE exclusions END || ',' AS remaining
  FROM customer_orders
  WHERE exclusions IS NOT NULL AND exclusions != 'null' AND exclusions != ''

  UNION ALL

  SELECT
    order_id,
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1)),
    SUBSTR(remaining, INSTR(remaining, ',') + 1)
  FROM split_exclusions
  WHERE remaining != ''
),
counted AS (
  SELECT
    pizza_toppings.topping_name,
    COUNT(*) AS times_excluded,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
  FROM split_exclusions
  JOIN pizza_toppings
    ON CAST(split_exclusions.topping_id AS INTEGER) = pizza_toppings.topping_id
  WHERE split_exclusions.topping_id != ''
  GROUP BY pizza_toppings.topping_name
)
SELECT topping_name, times_excluded
FROM counted
WHERE rnk = 1;


--Q4Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
WITH RECURSIVE
-- add a row number to each pizza so we can tell duplicate order lines apart
pizzas AS (
  SELECT
    ROW_NUMBER() OVER () AS record_id,
    order_id,
    pizza_id,
    CASE WHEN exclusions = 'null' OR exclusions = '' THEN NULL ELSE exclusions END AS exclusions,
    CASE WHEN extras = 'null' OR extras = '' THEN NULL ELSE extras END AS extras
  FROM customer_orders
),
-- split exclusions into one row per topping id
split_excl AS (
  SELECT record_id, order_id, pizza_id, exclusions || ',' AS remaining, '' AS topping_id
  FROM pizzas WHERE exclusions IS NOT NULL
  UNION ALL
  SELECT record_id, order_id, pizza_id,
    SUBSTR(remaining, INSTR(remaining, ',') + 1),
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1))
  FROM split_excl WHERE remaining != ''
),
-- split extras into one row per topping id
split_extra AS (
  SELECT record_id, order_id, pizza_id, extras || ',' AS remaining, '' AS topping_id
  FROM pizzas WHERE extras IS NOT NULL
  UNION ALL
  SELECT record_id, order_id, pizza_id,
    SUBSTR(remaining, INSTR(remaining, ',') + 1),
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1))
  FROM split_extra WHERE remaining != ''
),
-- reassemble exclusion names per pizza record
excl_names AS (
  SELECT se.record_id,
    GROUP_CONCAT(pt.topping_name, ', ') AS excl_list
  FROM split_excl se
  JOIN pizza_toppings pt ON CAST(se.topping_id AS INTEGER) = pt.topping_id
  WHERE se.topping_id != ''
  GROUP BY se.record_id
),
-- reassemble extra names per pizza record
extra_names AS (
  SELECT se.record_id,
    GROUP_CONCAT(pt.topping_name, ', ') AS extra_list
  FROM split_extra se
  JOIN pizza_toppings pt ON CAST(se.topping_id AS INTEGER) = pt.topping_id
  WHERE se.topping_id != ''
  GROUP BY se.record_id
)
SELECT
  pizzas.record_id,
  pizzas.order_id,
  pizza_names.pizza_name
    || CASE WHEN excl_names.excl_list IS NOT NULL
            THEN ' - Exclude ' || excl_names.excl_list ELSE '' END
    || CASE WHEN extra_names.extra_list IS NOT NULL
            THEN ' - Extra ' || extra_names.extra_list ELSE '' END
    AS order_item
FROM pizzas
JOIN pizza_names ON pizzas.pizza_id = pizza_names.pizza_id
LEFT JOIN excl_names ON pizzas.record_id = excl_names.record_id
LEFT JOIN extra_names ON pizzas.record_id = extra_names.record_id
ORDER BY pizzas.record_id;

--Q5Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH RECURSIVE
-- STEP 1: tag each pizza line
pizzas AS (
  SELECT
    ROW_NUMBER() OVER () AS record_id,
    order_id, pizza_id,
    CASE WHEN exclusions IN ('null','') THEN NULL ELSE exclusions END AS exclusions,
    CASE WHEN extras IN ('null','') THEN NULL ELSE extras END AS extras
  FROM customer_orders
),
-- STEP 2: split each pizza's STANDARD toppings into rows
standard AS (
  SELECT pizza_id, toppings || ',' AS remaining, '' AS topping_id
  FROM pizza_recipes
  UNION ALL
  SELECT pizza_id,
    SUBSTR(remaining, INSTR(remaining, ',') + 1),
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1))
  FROM standard WHERE remaining != ''
),
-- STEP 3a: split EXCLUSIONS into rows
excl AS (
  SELECT record_id, exclusions || ',' AS remaining, '' AS topping_id
  FROM pizzas WHERE exclusions IS NOT NULL
  UNION ALL
  SELECT record_id,
    SUBSTR(remaining, INSTR(remaining, ',') + 1),
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1))
  FROM excl WHERE remaining != ''
),
-- STEP 3b: split EXTRAS into rows
extra AS (
  SELECT record_id, extras || ',' AS remaining, '' AS topping_id
  FROM pizzas WHERE extras IS NOT NULL
  UNION ALL
  SELECT record_id,
    SUBSTR(remaining, INSTR(remaining, ',') + 1),
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1))
  FROM extra WHERE remaining != ''
),
-- STEP 4: build the final topping set for each pizza record
final_toppings AS (
  -- standard toppings that were NOT excluded
  SELECT
    p.record_id,
    pt.topping_name,
    -- 2x if this standard topping was ALSO added as an extra
    CASE WHEN e2.topping_id IS NOT NULL THEN '2x' ELSE '' END AS prefix
  FROM pizzas p
  JOIN standard s ON p.pizza_id = s.pizza_id AND s.topping_id != ''
  JOIN pizza_toppings pt ON CAST(s.topping_id AS INTEGER) = pt.topping_id
  -- drop excluded ones
  LEFT JOIN excl e1 ON p.record_id = e1.record_id AND e1.topping_id = s.topping_id
  -- check for 2x
  LEFT JOIN extra e2 ON p.record_id = e2.record_id AND e2.topping_id = s.topping_id
  WHERE e1.topping_id IS NULL

  UNION

  -- extras that are NOT already standard toppings (added-only ingredients, always 2x)
  SELECT
    p.record_id,
    pt.topping_name,
    '2x' AS prefix
  FROM pizzas p
  JOIN extra ex ON p.record_id = ex.record_id AND ex.topping_id != ''
  JOIN pizza_toppings pt ON CAST(ex.topping_id AS INTEGER) = pt.topping_id
  WHERE NOT EXISTS (
    SELECT 1 FROM standard s
    WHERE s.pizza_id = p.pizza_id AND s.topping_id = ex.topping_id
  )
)
-- STEP 5: assemble the string
SELECT
  ft.record_id,
  pn.pizza_name || ': ' ||
  GROUP_CONCAT(ft.prefix || ft.topping_name, ', ') AS ingredient_list
FROM final_toppings ft
JOIN pizzas p ON ft.record_id = p.record_id
JOIN pizza_names pn ON p.pizza_id = pn.pizza_id
GROUP BY ft.record_id, pn.pizza_name
ORDER BY ft.record_id;

--Q6What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH RECURSIVE
-- clean runner_orders so we know which orders were delivered
runner_orders_clean AS (
  SELECT order_id,
    CASE WHEN cancellation IN ('null','') THEN NULL ELSE cancellation END AS cancellation
  FROM runner_orders
),
-- split each pizza's standard toppings into rows
standard AS (
  SELECT pizza_id, toppings || ',' AS remaining, '' AS topping_id
  FROM pizza_recipes
  UNION ALL
  SELECT pizza_id,
    SUBSTR(remaining, INSTR(remaining, ',') + 1),
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1))
  FROM standard WHERE remaining != ''
)
SELECT
  pizza_toppings.topping_name,
  COUNT(*) AS times_used
FROM customer_orders
JOIN runner_orders_clean
  ON customer_orders.order_id = runner_orders_clean.order_id
JOIN standard
  ON customer_orders.pizza_id = standard.pizza_id AND standard.topping_id != ''
JOIN pizza_toppings
  ON CAST(standard.topping_id AS INTEGER) = pizza_toppings.topping_id
WHERE runner_orders_clean.cancellation IS NULL
GROUP BY pizza_toppings.topping_name
ORDER BY times_used DESC;

--D. Pricing and Ratings

--Q1If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
WITH runner_orders_clean AS (
  SELECT order_id,
    CASE WHEN cancellation IN ('null','') THEN NULL ELSE cancellation END AS cancellation
  FROM runner_orders
)
SELECT
  SUM(
    CASE WHEN customer_orders.pizza_id = 1 THEN 12
         WHEN customer_orders.pizza_id = 2 THEN 10
    END
  ) AS total_revenue
FROM customer_orders
JOIN runner_orders_clean
  ON customer_orders.order_id = runner_orders_clean.order_id
WHERE runner_orders_clean.cancellation IS NULL;

--Q2What if there was an additional $1 charge for any pizza extras?
--Add cheese is $1 extra

WITH RECURSIVE
runner_orders_clean AS (
  SELECT order_id,
    CASE WHEN cancellation IN ('null','') THEN NULL ELSE cancellation END AS cancellation
  FROM runner_orders
),
pizzas AS (
  SELECT
    ROW_NUMBER() OVER () AS record_id,
    order_id, pizza_id,
    CASE WHEN extras IN ('null','') THEN NULL ELSE extras END AS extras
  FROM customer_orders
),
-- split extras into one row per added topping
extra AS (
  SELECT record_id, extras || ',' AS remaining, '' AS topping_id
  FROM pizzas WHERE extras IS NOT NULL
  UNION ALL
  SELECT record_id,
    SUBSTR(remaining, INSTR(remaining, ',') + 1),
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1))
  FROM extra WHERE remaining != ''
)
SELECT
  -- base pizza revenue
  SUM(CASE WHEN p.pizza_id = 1 THEN 12 WHEN p.pizza_id = 2 THEN 10 END)
  -- plus $1 for each extra topping
  + (SELECT COUNT(*) FROM extra
     JOIN pizzas p2 ON extra.record_id = p2.record_id
     JOIN runner_orders_clean r2 ON p2.order_id = r2.order_id
     WHERE extra.topping_id != '' AND r2.cancellation IS NULL)
  AS total_revenue
FROM pizzas p
JOIN runner_orders_clean r ON p.order_id = r.order_id
WHERE r.cancellation IS NULL;

--If you want to seperate the Two and add it to be easier
--FIRST QUERY
WITH runner_orders_clean AS (
  SELECT order_id,
    CASE WHEN cancellation IN ('null','') THEN NULL ELSE cancellation END AS cancellation
  FROM runner_orders
)
SELECT
  SUM(CASE WHEN customer_orders.pizza_id = 1 THEN 12
           WHEN customer_orders.pizza_id = 2 THEN 10 END) AS base_revenue
FROM customer_orders
JOIN runner_orders_clean
  ON customer_orders.order_id = runner_orders_clean.order_id
WHERE runner_orders_clean.cancellation IS NULL;

--SECOND QUERY
WITH RECURSIVE
runner_orders_clean AS (
  SELECT order_id,
    CASE WHEN cancellation IN ('null','') THEN NULL ELSE cancellation END AS cancellation
  FROM runner_orders
),
pizzas AS (
  SELECT
    ROW_NUMBER() OVER () AS record_id,
    order_id,
    CASE WHEN extras IN ('null','') THEN NULL ELSE extras END AS extras
  FROM customer_orders
),
extra AS (
  SELECT record_id, order_id, extras || ',' AS remaining, '' AS topping_id
  FROM pizzas WHERE extras IS NOT NULL
  UNION ALL
  SELECT record_id, order_id,
    SUBSTR(remaining, INSTR(remaining, ',') + 1),
    TRIM(SUBSTR(remaining, 1, INSTR(remaining, ',') - 1))
  FROM extra WHERE remaining != ''
)
SELECT COUNT(*) AS extras_count
FROM extra
JOIN runner_orders_clean ON extra.order_id = runner_orders_clean.order_id
WHERE extra.topping_id != ''
  AND runner_orders_clean.cancellation IS NULL;

--Q3The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
CREATE TABLE ratings (
  order_id INTEGER,
  rating INTEGER
);

INSERT INTO ratings (order_id, rating) VALUES
  (1, 4),
  (2, 5),
  (3, 3),
  (4, 2),
  (5, 4),
  (7, 5),
  (8, 3),
  (10, 4);

--Q4Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
--customer_id
--order_id
--runner_id
--rating
--order_time
--pickup_time
--Time between order and pickup
--Delivery duration
--Average speed
--Total number of pizzas
WITH runner_orders_clean AS (
  SELECT order_id, runner_id,
    CASE WHEN pickup_time IN ('null','') THEN NULL ELSE pickup_time END AS pickup_time,
    CAST(TRIM(REPLACE(distance, 'km', '')) AS REAL) AS distance,
    CAST(TRIM(REPLACE(REPLACE(REPLACE(duration,'minutes',''),'minute',''),'mins','')) AS REAL) AS duration,
    CASE WHEN cancellation IN ('null','') THEN NULL ELSE cancellation END AS cancellation
  FROM runner_orders
)
SELECT
  customer_orders.customer_id,
  customer_orders.order_id,
  runner_orders_clean.runner_id,
  ratings.rating,
  customer_orders.order_time,
  runner_orders_clean.pickup_time,
  (JULIANDAY(runner_orders_clean.pickup_time) - JULIANDAY(customer_orders.order_time)) * 1440 AS mins_to_pickup,
  runner_orders_clean.duration AS delivery_duration,
  ROUND(runner_orders_clean.distance / runner_orders_clean.duration * 60, 1) AS avg_speed_kmh,
  COUNT(customer_orders.pizza_id) AS total_pizzas
FROM customer_orders
JOIN runner_orders_clean
  ON customer_orders.order_id = runner_orders_clean.order_id
JOIN ratings
  ON customer_orders.order_id = ratings.order_id
WHERE runner_orders_clean.cancellation IS NULL
GROUP BY
  customer_orders.customer_id,
  customer_orders.order_id,
  runner_orders_clean.runner_id,
  ratings.rating,
  customer_orders.order_time,
  runner_orders_clean.pickup_time,
  runner_orders_clean.duration,
  runner_orders_clean.distance;  

--Q5If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
WITH runner_orders_clean AS (
  SELECT order_id,
    CAST(TRIM(REPLACE(distance, 'km', '')) AS REAL) AS distance,
    CASE WHEN cancellation IN ('null','') THEN NULL ELSE cancellation END AS cancellation
  FROM runner_orders
)
SELECT
  -- revenue from pizzas
  SUM(CASE WHEN customer_orders.pizza_id = 1 THEN 12
           WHEN customer_orders.pizza_id = 2 THEN 10 END)
  -- minus runner pay: total km × $0.30
  - (SELECT SUM(distance) * 0.30
     FROM runner_orders_clean
     WHERE cancellation IS NULL)
  AS money_left_over
FROM customer_orders
JOIN runner_orders_clean
  ON customer_orders.order_id = runner_orders_clean.order_id
WHERE runner_orders_clean.cancellation IS NULL;  

--E. Bonus Questions
--If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
-- Give Supreme a name and id (it becomes pizza_id 3)
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');

-- Give Supreme its recipe: ALL toppings (ids 1 through 12)
INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');