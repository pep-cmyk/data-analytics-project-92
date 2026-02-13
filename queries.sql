-- customers_count
select count(customer_id) as customers_count
from customers;
--top_10_total_income
select
    e.first_name || ' ' || e.last_name as seller,
    --слепляю имена
    count(s.quantity) as operations,
    --считаю кол-во продаж
    floor(sum(p.price * s.quantity)) as income
    --с округлением считаю продажи
from employees as e
inner join sales as s
    on e.employee_id = s.sales_person_id
    --присоединяю sales для quantity и ключа к products
inner join products as p
    on s.product_id = p.product_id
    -- присоединяю products для цены
group by e.employee_id
order by income desc
limit 10;
--lowest_average_income
select
    e.first_name || ' ' || e.last_name as seller,
    --слепляю имена
    floor(avg(s.quantity * p.price)) as average_income
    --средний доход каждого продавца с округлением
from employees as e
inner join sales as s
    on e.employee_id = s.sales_person_id
inner join products as p
    on s.product_id = p.product_id
group by e.employee_id
having
    avg(sales.quantity * products.price) < (
        select
            floor(
                avg(sales.quantity * products.price)
            )
        from sales
        inner join products
            on sales.product_id = products.product_id
    )
    --тут подзапросом прописываю средний доход по всем продавцам
order by average_income asc;
-- day_of_the_week_income
select
    e.first_name || ' ' || e.last_name as seller,
    --имена
    trim(to_char(s.sale_date, 'day')) as day_of_week,
    --беру название дней недели и обрезаю пробелы в конце
    floor(sum(p.price * s.quantity)) as income
    --выручка с округлением
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    day_of_week,
    e.first_name || ' ' || e.last_name,
    extract(isodow from s.sale_date)
    --добавляю отдельно номер дня недели по ISO, чтобы пн был 1
order by
    extract(isodow from s.sale_date) asc,
    --сортирую по iso, чтобы начать с пн
    seller;
-- age_groups
select
    case
        when c.age between 16 and 25 then '16-25'
        when c.age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    --разбиваю по категориям
    count(c.customer_id) as age_count
    --счет клиентов
from customers as c
group by
    case
        when c.age between 16 and 25 then '16-25'
        when c.age between 26 and 40 then '26-40'
        else '40+'
    end
order by age_category;
-- customers_by_month
select
    to_char(date_trunc('month', s.sale_date), 'YYYY-MM') as selling_month,
    --беру месяц и привожу его в нужный мне формат
    count(distinct s.customer_id) as total_customers,
    --счет уникальных клиентов
    floor(sum(s.quantity * p.price)) as income
    --округленная выручка
from sales as s
left join products as p
    on s.product_id = p.product_id
group by date_trunc('month', s.sale_date)
order by selling_month asc;
-- special_offer
select
    subquery.customer,
    subquery.sale_date,
    subquery.seller
    --собираю нужные столбцы из подзапроса
from (
    select
        s.sale_date,
        p.price,
        s.customer_id,
        row_number()
            over (partition by s.customer_id order by s.sale_date asc)
            as rn, --включаю счетчик рядов
        c.first_name || ' ' || c.last_name as customer,
        e.first_name || ' ' || e.last_name as seller
    from sales as s
    left join products as p
        on s.product_id = p.product_id
    left join customers as c
        on s.customer_id = c.customer_id
    left join employees as e
        on s.sales_person_id = e.employee_id
    where p.price = 0
) as subquery
--заворачиваю все в подзапрос, чтобы отфильтровать по rn=1
where subquery.rn = 1
order by subquery.customer_id;
