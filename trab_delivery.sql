
CREATE database db_deliverycenter;

USE db_deliverycenter;

CREATE TABLE `db_deliverycenter`.`channels` (
  `channel_id` int DEFAULT NULL,
  `channel_name` text,
  `channel_type` text);

CREATE TABLE `db_deliverycenter`.`hubs` (
  `hub_id` int DEFAULT NULL,
  `hub_name` text,
  `hub_city` text,
  `hub_state` text,
  `hub_latitude` double DEFAULT NULL,
  `hub_longitude` double DEFAULT NULL);

CREATE TABLE `db_deliverycenter`.`stores` (
  `store_id` int DEFAULT NULL,
  `hub_id` int DEFAULT NULL,
  `store_name` text,
  `store_segment` text,
  `store_plan_price` int DEFAULT NULL,
  `store_latitude` text,
  `store_longitude` text);


CREATE TABLE `db_deliverycenter`.`drivers` (
  `driver_id` int DEFAULT NULL,
  `driver_modal` text,
  `driver_type` text);


CREATE TABLE `db_deliverycenter`.`deliveries` (
  `delivery_id` int DEFAULT NULL,
  `delivery_order_id` int DEFAULT NULL,
  `driver_id` int DEFAULT NULL,
  `delivery_distance_meters` int DEFAULT NULL,
  `delivery_status` text);


CREATE TABLE `db_deliverycenter`.`payments` (
  `payment_id` int DEFAULT NULL,
  `payment_order_id` int DEFAULT NULL,
  `payment_amount` double DEFAULT NULL,
  `payment_fee` double DEFAULT NULL,
  `payment_method` text,
  `payment_status` text);


CREATE TABLE `db_deliverycenter`.`orders` (
  `order_id` int DEFAULT NULL,
  `store_id` int DEFAULT NULL,
  `channel_id` int DEFAULT NULL,
  `payment_order_id` int DEFAULT NULL,
  `delivery_order_id` int DEFAULT NULL,
  `order_status` text,
  `order_amount` double DEFAULT NULL,
  `order_delivery_fee` int DEFAULT NULL,
  `order_delivery_cost` text,
  `order_created_hour` int DEFAULT NULL,
  `order_created_minute` int DEFAULT NULL,
  `order_created_day` int DEFAULT NULL,
  `order_created_month` int DEFAULT NULL,
  `order_created_year` int DEFAULT NULL,
  `order_moment_created` text,
  `order_moment_accepted` text,
  `order_moment_ready` text,
  `order_moment_collected` text,
  `order_moment_in_expedition` text,
  `order_moment_delivering` text,
  `order_moment_delivered` text,
  `order_moment_finished` text,
  `order_metric_collected_time` text,
  `order_metric_paused_time` text,
  `order_metric_production_time` text,
  `order_metric_walking_time` text,
  `order_metric_expediton_speed_time` text,
  `order_metric_transit_time` text,
  `order_metric_cycle_time` text);

-- 1- Qual o número de hubs por cidade?
SELECT COUNT(hub_city),hub_city FROM hubs GROUP BY hub_city;

-- 2- Qual o número de pedidos (orders) por status?
SELECT COUNT(order_id) AS pedidos, order_status FROM orders GROUP BY order_status;

-- 3- Qual o número de lojas (stores) por cidade dos hubs?
SELECT COUNT(store_id), h.hub_city FROM stores AS s 
INNER JOIN hubs AS h ON s.hub_id = h.hub_Id
GROUP BY hub_city;

-- 4- Qual o maior e o menor valor de pagamento (payment_amount) registrado?
SELECT MAX(payment_amount), MIN(payment_amount) FROM payments;
-- 5- Qual tipo de driver (driver_type) fez o maior número de entregas?
select COUNT(driver_type), driver_type FROM drivers
GROUP BY driver_type ORDER BY max(driver_type);
-- 6- Qual a distância média das entregas por tipo de driver (driver_modal)?

SELECT AVG(delivery_distance_meters) 
FROM drivers AS dr 
INNER JOIN deliveries AS de 
ON dr.driver_id = de.driver_id 
GROUP BY driver_modal 
LIMIT 10;

-- 7- Qual a média de valor de pedido (order_amount) por loja, em ordem decrescente?

SELECT s.store_id,s.store_name,
AVG(o.order_amount) AS media_valor_pedido
FROM stores s
JOIN orders o ON s.store_id = o.store_id
GROUP BY s.store_id,s.store_name
ORDER BY media_valor_pedido DESC;

-- 8- Existem pedidos que não estão associados a lojas? Se caso positivo, quantos?
 
SELECT COUNT(*) AS orders_sem_loja
FROM orders
WHERE store_id is null;
 
-- 9- Qual o valor total de pedido (order_amount) no channel 'FOOD PLACE'?
SELECT SUM(o.order_amount) AS total_pedido
FROM orders AS o
INNER JOIN channels AS c ON o.channel_id = c.channel_id
WHERE c.channel_name = 'FOOD PLACE';

-- 10- Quantos pagamentos foram cancelados (chargeback)?

SELECT COUNT(*) AS pagamentos_cancelados
FROM payments
WHERE payment_status = 'chargeback';

-- 11- Qual foi o valor médio dos pagamentos cancelados (chargeback)?

SELECT AVG(payment_amount) AS media_pagamentos_cancelados
FROM payments
WHERE payment_status = 'chargeback';

-- 12- Qual a média do valor de pagamento por método de pagamento (payment_method) em ordem decrescente?
SELECT payment_method, AVG(payment_amount) AS media_pagamento_metodo
FROM payments
GROUP BY payment_method
ORDER BY media_pagamento_metodo DESC;

-- 13- Quais métodos de pagamento tiveram valor médio superior a 100?
SELECT payment_method
FROM payments
GROUP BY payment_method
HAVING AVG(payment_amount) > 100;

-- 14- Qual a média de valor de pedido (order_amount) por estado do hub (hub_state), segmento da loja (store_segment) e tipo de canal (channel_type)?

SELECT hu.hub_state, s.store_segment, ch.channel_type, AVG(ord.order_amount) AS average_order_amount
FROM orders AS ord
INNER JOIN stores AS s ON ord.store_id = s.store_id
INNER JOIN channels AS ch ON ord.channel_id = ch.channel_id
INNER JOIN hubs AS hu ON s.hub_id = hu.hub_id
GROUP BY hu.hub_state, s.store_segment, ch.channel_type;

-- 15- Qual estado do hub (hub_state), segmento da loja (store_segment) e tipo de canal (channel_type) teve média de valor de pedido (order_amount) maior que 450? 

SELECT hu.hub_state, s.store_segment, ch.channel_type
FROM hubs AS hu
LEFT JOIN stores AS s ON hu.hub_id = s.hub_id
LEFT JOIN orders AS ord ON s.store_id = ord.store_id
LEFT JOIN channels AS ch ON ord.channel_id = ch.channel_id
GROUP BY hu.hub_state, s.store_segment, ch.channel_type
HAVING AVG(ord.order_amount) > 450;



