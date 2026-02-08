--top_10_total_income

select
	e.first_name || ' ' ||  e.last_name as seller, -- слепляю имена
	sum(s.quantity) as operations, -- продажи, шт
	floor(sum(p.price * s.quantity)) as income -- продажи в валюте
from employees e
inner join sales s
	on e.employee_id  = s.sales_person_id -- присоединяю sales для quantity и ключа к products
inner join products p
	on p.product_id = s.product_id  -- присоединяю products для цены
group by e.employee_id -- группировка, чтобы не было 1000+ продавцов, когда по факту с продажами у нас 22 человека
order by income desc -- сортировка
limit 10; -- ограничение выдачи


--lowest_average_income.sql

select
	e.first_name || ' ' || e.last_name as seller, -- беру полное имя
	floor(sum(s.quantity *p.price)/sum(s.quantity)) as average_income -- считаю среднюю прибыль и сразу округляю
from employees e 
inner join sales s 
	on e.employee_id = s.sales_person_id -- присоединяю sales для quantity и ключа к products
inner join products p
	on s.product_id = p.product_id -- присоединяю products для цены
group by e.employee_id
having sum(s.quantity *p.price)/count(s.quantity) < (select 
														floor(sum(s.quantity *p.price)/count(s.quantity))
													from sales s
													inner join products p 
														on s.product_id = p.product_id) -- подзапрос, в котором считаю среднюю выручку по всем продавцам
order by average_income asc;


-- day_of_the_week_income.sql

select
	e.first_name || ' ' || e.last_name as seller, -- имена
	to_char(s.sale_date, 'day') as day_of_week, -- название дня недели
	floor(sum(p.price * s.quantity)) as income -- считаю прибыль
from sales s
inner join employees e
	on e.employee_id = s.sales_person_id -- присоединяю sales для даты продаж
inner join products p 
	on s.product_id = p.product_id -- присоединяю products для цены
group by
	day_of_week,
	e.first_name || ' ' || e.last_name,
	extract(ISODOW from s.sale_date) -- добавляю отдельно номер дня недели по ISO, чтобы пн был 1, а не вс было 1
order by
	extract(ISODOW from s.sale_date) asc, -- соритрую по номеру дня недели и по имени
	seller;


-- age_groups

select
	case
		when c.age between 16 and 25 then '16-25'
		when c.age between 26 and 45 then '26-45'
		else '40+'
		end as age_category, -- разбиваю на категории
	count(c.customer_id) as age_count -- считаю покупателей
from customers c
group by case
		when c.age between 16 and 25 then '16-25'
		when c.age between 26 and 45 then '26-45'
		else '40+'
		end -- группирую по категориям
order by age_category;


-- customers_by_month

select
	to_char(date_trunc('month', s.sale_date), 'YYYY-MM') as selling_month, --обрезаю даты до месяца и превращаю их в нужный формат
	count(distinct s.customer_id) as total_customers,-- считаю уникальных покупателей
	floor(sum(s.quantity * p.price)) as income -- считаю выручку
from sales s
left join products p
	on s.product_id = p.product_id -- присоединяю для цен
group by date_trunc('month', s.sale_date) -- группировка по selling_month
order by selling_month ASC;


-- special_offer

select				-- беру нужные мне столбцы из подзапроса
	customer,
	sale_date,
	seller
from (select		-- создаю подзапрос для того, чтобы потом отфильтровать результат по rn = 1 
		row_number() over(partition by s.customer_id order by sale_date asc) as rn, -- в окне включаю счетчик рядов, чтобы взять самую первую покупку ждя каждого покупателя
		c.first_name || ' ' || c.last_name as customer,
		s.sale_date,
		e.first_name || ' ' || e.last_name as seller,
		p.price,
		s.customer_id
	from sales s
	left join products p
		on s.product_id = p.product_id	-- присоединяю для цены
	left join customers c
		on s.customer_id = c.customer_id -- присоединяю для имени покупателя
	left join employees e				-- присоединяю для имени продавца
		on e.employee_id = s.sales_person_id) subquery -- заворачиваю в подзапрос
where rn = 1 and price = 0 -- фильтрую, чтобы оставить только тех, у кого цена первой покупки = 0

order by customer_id
