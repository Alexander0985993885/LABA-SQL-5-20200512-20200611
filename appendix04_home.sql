/*
4.3
вывести номер, статус и дату заказа (таблица orders), имя заказчика (таблица customers) и его телефон (таблица contacts),
имя ответственного менеджера и его телефон (таблица employees) (если нет данных по менеджеру заменить на 'N/A')
для сентября 2016 (примечание 01.09.2016 - 30.09.2016)
отсортировать по статусу и дате заказа (6 баллов)
*/
SELECT
	t1.order_id order_num ,
	t1.status order_status ,
	t1.order_date ,
	t2.name customer_name ,
	t3.phone customer_phone,
	COALESCE(t4.first_name + ' ' + LEFT(t4.last_name, 1)+ '.', 'N/A') sales_manager_name ,
	COALESCE(t4.phone, 'N/A') sales_manager_phone
FROM
	db_laba.dbo.orders t1 --select * from db_laba.dbo.orders
JOIN db_laba.dbo.customers t2 ON --select * from db_laba.dbo.customers
	t2.customer_id = t1.customer_id
JOIN db_laba.dbo.contacts t3 ON --select * from db_laba.dbo.contacts
	t3.customer_id = t2.customer_id
left JOIN db_laba.dbo.employees t4 ON --select * from db_laba.dbo.employees
	t4.employee_id = t1.salesman_id
WHERE
	t1.order_date BETWEEN '2016-09-01' AND '2016-09-30' --MONTH(t1.order_date)=9 AND YEAR(t1.order_date)=2016
ORDER BY t1.status,
	t1.order_date;

/*
 
 5.2. Выведите ID и статус заказа, имя продавца и его телефон
   для всех заказов, которые сделал самый лучший продавец 2016 года (продал больше всего товара в денежном эквиваленте)
   Отсортируйте на ваше усмотрение (5 баллов)
   */
 
SELECT
	o.order_id ,
	o.status ,
	e.first_name ,
	e.phone
FROM
	db_laba.dbo.orders o
JOIN db_laba.dbo.employees e ON
	o.salesman_id = e.employee_id
WHERE
	o.salesman_id = (
	SELECT
		temp_o.salesman_id
	FROM
		(
		SELECT
			TOP (1) 
			o.salesman_id , SUM(oi.quantity*oi.unit_price) order_sum
		FROM
			db_laba.dbo.order_items oi
		JOIN db_laba.dbo.orders o ON
			o.order_id = oi.order_id
		WHERE
			o.salesman_id IS NOT NULL
			AND o.order_date BETWEEN '2016-01-01' AND '2016-12-31'
		GROUP BY
			o.salesman_id
		ORDER BY
			order_sum DESC) temp_o)
ORDER BY
	o.order_id DESC;

/*
5.4
вывести сумму маржи (примечание: сумма(quantity * list_price) - сума(quantity * standard_cost) ),
имя клиента и год заказа
сгруппировать по имени клиента и году заказа
для клиентов со средним количеством заказанных продуктов более чем среднее
значение заказанных продуктов в 2016 году
отсортировать на Ваше усмотрение (6 баллов)
*/
--v1 incorrect
SELECT
	(SUM(oi.quantity*p.list_price)-SUM(oi.quantity*p.standard_cost)) margin,
	cust.name,
	YEAR(o.order_date) order_year
FROM
	db_laba.dbo.orders o
JOIN db_laba.dbo.order_items oi ON
	oi.order_id = o.order_id
JOIN db_laba.dbo.products p ON
	oi.product_id = p.product_id
JOIN db_laba.dbo.customers cust ON
	o.customer_id = cust.customer_id
GROUP BY
	cust.name,
	YEAR(o.order_date)
HAVING
	AVG(oi.quantity)> (
	SELECT
		AVG(oi.quantity) avg_quant
	FROM
		db_laba.dbo.orders o
	JOIN db_laba.dbo.order_items oi ON
		oi.order_id = o.order_id
	WHERE
		YEAR(o.order_date)= 2016)
ORDER BY
	order_year ASC,
	margin DESC;

--v2 correct
SELECT
	(SUM(prod.list_price*oi.quantity)-SUM(oi.quantity*prod.standard_cost)) margin ,
	cust.name ,
	YEAR(ord.order_date) OrderYear
FROM
	db_laba.dbo.customers cust
INNER JOIN db_laba.dbo.orders ord ON
	ord.customer_id = cust.customer_id
INNER JOIN db_laba.dbo.order_items oi ON
	oi.order_id = ord.order_id
INNER JOIN db_laba.dbo.products prod ON
	prod.product_id = oi.product_id
WHERE
	cust.customer_id IN (
	SELECT
		ord.customer_id
	FROM
		db_laba.dbo.orders ord
	JOIN db_laba.dbo.order_items oi ON
		oi.order_id = ord.order_id
	GROUP BY
		ord.customer_id
	HAVING
		AVG(oi.quantity)> (
		SELECT
			AVG (oi.quantity)
		FROM
			db_laba.dbo.order_items oi
		JOIN db_laba.dbo.orders ord ON
			ord.order_id = oi.order_id
		WHERE
			YEAR(ord.order_date) = 2016) )
GROUP BY
	cust.name ,
	YEAR(ord.order_date)
ORDER BY
	2,
	3,
	1;

--6.2
--Выведите 5 первых четных продавцов (примечание: 2, 4, 6, 8 и 10) сортируя по количеству
--проданных продуктов за все время, но только четные места  (5 баллов)

select
	x1.first_name,
	x1.last_name,
	x1.phone ,
	x1.total_quantity,
	x1.row_num
from
	(
	select
		x0.first_name,
		x0.last_name,
		x0.phone,
		x0.total_quantity,
		row_number () over (order by x0.total_quantity desc) as row_num
	from
		(
		select
			e.first_name, e.last_name, e.phone, sum (oi.quantity) total_quantity
		from
			db_laba.dbo.order_items oi
		join db_laba.dbo.orders o on
			o.order_id = oi.order_id
		join db_laba.dbo.employees e on
			e.employee_id = o.salesman_id
		where
			o.salesman_id is not null
		group by
			e.first_name, e.last_name, e.phone) x0) x1
where
	x1.row_num <= 10
	and x1.row_num % 2 = 0;

select 13 % 10;

select 13 % 2;

select 10 % 2;



/*
7.4
Обновить колонку employees_test_student.email таким образом,
что бы остался только домен (пример sample@cool.com => cool.com)
для всех сотрудников длина фамилии которых до 5 символов
написать запрос для проверки
*/

UPDATE
	db_laba.dbo.employees_test_student
SET
	email = SUBSTRING(email, CHARINDEX('@', email)+ 1, LEN(email))
WHERE
	student_name = 'm.belko'
	AND LEN(last_name) <= 5;
--check
 SELECT
	email,
	SUBSTRING(email, CHARINDEX('@', email)+ 1, LEN(email))
FROM
	db_laba.dbo.employees_test_student t1
WHERE
	t1.student_name = 'm.belko'
	AND LEN(t1.last_name) <= 5;

SELECT
	*
FROM
	db_laba.dbo.employees_test_student t1
WHERE
	t1.student_name = 'm.belko'
	
	
	