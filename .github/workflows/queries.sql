select
	e.first_name || ' ' ||  e.last_name as seller, -- слепляю имена
	SUM(s.quantity) as operations, -- количество продаж
	floor(SUM(p.price * s.quantity)) as income -- сумма продаж
from employees e
inner join sales s
	on e.employee_id  = s.sales_person_id -- присоединяю sales для quantity и ключа к products
inner join products p
	on p.product_id = s.product_id  -- присоединяю products для цены
group by e.employee_id -- группировка, чтобы не было 1000+ продавцов, когда по факту с продажами у нас 22 человека
order by income desc -- сортировка
limit 10 -- ограничение выдачи