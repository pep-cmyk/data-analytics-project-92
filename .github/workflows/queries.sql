--top_10_total_income

select
	e.first_name || ' ' ||  e.last_name as seller, -- слепляю имена
	COUNT(s.quantity) as operations, -- количество продаж
	floor(sum(p.price * s.quantity)) as income -- сумма продаж с округлением
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
	floor(sum(s.quantity *p.price)/count(s.quantity)) as average_income -- считаю среднюю прибыль и сразу округляю
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