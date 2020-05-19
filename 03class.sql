/*
 * #############################
 * #     Занятие 3             #  
 * #     Функции агрегации     #
 * #############################
 */

/*
 * +-----+
 * | SUM |
 * +-----+
 */

-- вывести содержимое таблицы продуктов
-- 1/21
SELECT
	product_id,
	product_name,
	description,
	standard_cost,
	list_price,
	category_id
FROM
	db_laba.dbo.products;

-- вывести общую сумму цены на сайте
-- 2/21
 SELECT
	SUM(list_price) as total_price 
FROM
	db_laba.dbo.products;

/*
 * +-----+
 * | AVG |
 * +-----+
 */
-- вывести среднюю цену продукта на сайте
-- 3/21
 SELECT
	AVG(list_price) avg_price
FROM
	db_laba.dbo.products;

/*
 * +-------+
 * | COUNT |
 * +-------+
 */

-- ИСПОЛЬЗОВАНИЕ COUNT СО СТРОКАМИ, А НЕ ЗНАЧЕНИЯМИ 
-- вывести общее количество строк в таблице заказов
-- 4/21
 SELECT
	*,
	1 as one, 112323 as num_list, 'qewrqewrer' as dumy_text, getdate()
 --COUNT(*)
FROM
	db_laba.dbo.orders;

select 1; -- select 1 from dual; in oracle db

-- вывести количество менеджеров продаж и общее количество строк таблицы заказов
-- 5/21
 SELECT
 	COUNT(*) AS count_all,
	COUNT(salesman_id) AS count_salesman,
	COUNT(1) AS count_all_2,
	COUNT('qqq') AS count_all_3
FROM
	db_laba.dbo.orders;
--where salesman_id is null;

-- вывести количество продуктов с уникальными ценами
-- 6/21
 SELECT
	COUNT(DISTINCT list_price),
	COUNT(list_price)--,
	--COUNT(sum(list_price))
FROM
	db_laba.dbo.products;

-- 7/21
SELECT
	COUNT(list_price) count_list_price
FROM
	db_laba.dbo.products;

/*
 * +-----+
 * | MIN |
 * +-----+
 */

-- вывести минимальную цену на сайте
-- 8/21
 SELECT
	MIN(list_price)
FROM
	db_laba.dbo.products;

/*
 * +-----+
 * | MAX |
 * +-----+
 */

-- вывести максимальную цену на сайте
-- 9/21
 SELECT
	MAX(list_price)
FROM
	db_laba.dbo.products;

/*
 * +----------------------+
 * | Предложение GROUP BY |
 * +----------------------+
 */

-- вывести суммарное значение цены для каждой категории
-- отсортировать по сумму по убыванию
-- 10/21
 SELECT
	SUM(p.list_price) as sum_list_price,
	p.category_id
FROM
	db_laba.dbo.products as p
GROUP BY
	p.category_id
	--,standard_cost 
order by 1 desc;

-- вывести среднее значение цены для каждой категории
-- для товаров стандартная цена которых выше 1000
-- 11/21
SELECT
	AVG(p.list_price) avg_list_price,
	round(AVG(p.list_price), 2) raunded_avg_list_price,
	round(AVG(p.list_price), -1) raunded_avg_list_price_minus_1,
	CAST(round(AVG(p.list_price), 2) AS DECIMAL(10, 2)) raunded_avg_list_price_2,
	CONVERT(DECIMAL(10, 2), round(AVG(p.list_price), 2)) raunded_avg_list_price_2_II,
	p.category_id
FROM
	db_laba.dbo.products p
WHERE
	p.standard_cost > 1000
GROUP BY
	p.category_id
order by 1;
/*
1979.018823	1
2007.823333	5
2642.375000	2*/
-- 12/21
select 1 + 2;
select '1' + 2;
select '1' + '2';
select 1 + '2';
select 'qqq' + 'ssss';
select 'qqq' + 2; --: Conversion failed when converting the varchar value 'qqq' to data type int.
SELECT 1 + null;
select '1' + CAST(23333 AS varchar(40))
select 1 + CAST(2 AS varchar(5))


-- вывести 5 первых строк таблицы  деталей заказов
-- 13/21
SELECT TOP (5)
	*
FROM 
 	db_laba.dbo.order_items
 	order by 1, 2;

-- вывести суммы в разрезе одного заказа
-- 14/21
SELECT
	SUM(oi.unit_price * oi.quantity) sale,
	oi.order_id
FROM
	db_laba.dbo.order_items oi
GROUP BY
	oi.order_id;

select * FROM
	db_laba.dbo.order_items oi ;

-- вывести суммы в разрезе одного заказа
-- для количества в одном заказе не менее 100 штук
-- 15/21
 SELECT
	SUM(oi.unit_price * oi.quantity) sale,
	oi.order_id
FROM
	db_laba.dbo.order_items oi
WHERE
	oi.quantity >= 100
GROUP BY
	oi.order_id;

-- вывести суммы проданых продуктов в разрезе продукта (сгруппировав по product_id)
-- отсортировать по убыванию суммы
-- 16/21
 SELECT
	SUM(oi.unit_price * oi.quantity) sale,
	oi.product_id
FROM
	db_laba.dbo.order_items oi
GROUP BY
	oi.product_id
ORDER BY 1 DESC;

--SELECT * from order_items oi where product_id = 1
--SELECT * from products 
--1	G.Skill Ripjaws V Series	Speed:DDR4-3000,Type:288-pin DIMM,CAS:15Module:8x8GBSize:64GB	450.36	640.99	5
/*
 * +--------------------+
 * | Предложение HAVING |
 * +--------------------+
 */

-- вывести к-во (сумму) проданных продуктов в разрезе продукта (сгруппировав по product_id)
-- для продуктов которые продали не менее 500 шт
-- отсортировать по убыванию к-ва
-- 17/21
 SELECT
	SUM(oi.quantity) quantity_amount,
	oi.product_id
FROM
	db_laba.dbo.order_items oi
--where SUM(oi.quantity) >= 500
--where oi.quantity >= 75--500
GROUP BY
	oi.product_id
HAVING 
	SUM(oi.quantity) >= 500
ORDER BY 1 DESC;

-- вывести суммы продаж в разрезе продукта
-- для продуктов которые продали не менее 500 шт
-- отсортировать по убыванию к-ва
-- 18/21
 SELECT
	SUM(oi.unit_price * oi.quantity) sale,
	--SUM(oi.quantity),
	oi.product_id
FROM
	db_laba.dbo.order_items oi
GROUP BY
	oi.product_id
HAVING --quantity > 10
	SUM(oi.quantity) >= 500
ORDER BY 1 DESC;

-- вывести номера заказов и сумму чека
-- для заказов с не менее 10 позиций
-- отсортировать по убыванию суммы
-- 19/21
 SELECT
	--COUNT(oi.item_id), -- for check
	oi.order_id,
	SUM(oi.unit_price * oi.quantity) sale
FROM
	db_laba.dbo.order_items oi
GROUP BY
	oi.order_id
HAVING COUNT(oi.item_id) >= 10
ORDER BY 2 DESC;

-- вывести топ 5 продаваемых продуктов и их кол-во
-- отсортировать по убыванию ко-ва
-- 20/21
 SELECT TOP(5)
	SUM(oi.quantity) sum_quantity,
	oi.product_id
FROM
	db_laba.dbo.order_items oi
GROUP BY
	oi.product_id
ORDER BY 1 DESC;

-- вывести топ 5 не продаваемых продуктов и их кол-во
-- отсортировать по убыванию ко-ва
-- 21/21
 SELECT TOP(5)
	SUM(oi.quantity) sum_quantity,
	oi.product_id
FROM
	db_laba.dbo.order_items oi
GROUP BY
	oi.product_id
ORDER BY 1;

