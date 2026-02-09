-- customers_count
select count(customer_id) as customers_count
from customers;
--top_10_total_income
select
    e.first_name || ' ' || e.last_name as seller,
    count(s.quantity) as operations,
    floor(sum(p.price * s.quantity)) as income
from employees as e
inner join sales as s
    on e.employee_id = s.sales_person_id
inner join products as p
    on s.product_id = p.product_id
group by e.employee_id
order by income desc
limit 10;
--lowest_average_income
select
    e.first_name || ' ' || e.last_name as seller,
    floor(sum(s.quantity * p.price) / count(s.quantity)) as average_income
from employees as e
inner join sales as s
    on e.employee_id = s.sales_person_id
inner join products as p
    on s.product_id = p.product_id
group by e.employee_id
having
    sum(s.quantity * p.price) / count(s.quantity) < (
        select floor(sum(s.quantity * p.price) / count(s.quantity))
        from sales as s
        inner join products as p
            on s.product_id = p.product_id
    )
order by average_income asc;
-- day_of_the_week_income
select
    e.first_name || ' ' || e.last_name as seller,
    trim(to_char(s.sale_date, 'day')) as day_of_week,
    floor(sum(p.price * s.quantity)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    day_of_week,
    e.first_name || ' ' || e.last_name,
    extract(isodow from s.sale_date)
order by
    extract(isodow from s.sale_date) asc,
    seller;
-- age_groups
select
    case
        when c.age between 16 and 25 then '16-25'
        when c.age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    count(c.customer_id) as age_count
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
    count(distinct s.customer_id) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from sales as s
left join products as p
    on s.product_id = p.product_id
group by date_trunc('month', s.sale_date)
order by selling_month asc;
-- special_offer
select
    customer,
    sale_date,
    seller
from (
    select
        s.sale_date,
        p.price,
        s.customer_id,
        row_number()
            over (partition by s.customer_id order by sale_date asc)
            as rn,
        c.first_name || ' ' || c.last_name as customer,
        e.first_name || ' ' || e.last_name as seller
    from sales as s
    left join products as p
        on s.product_id = p.product_id
    left join customers as c
        on s.customer_id = c.customer_id
    left join employees as e
        on s.sales_person_id = e.employee_id
) as subquery
where rn = 1 and price = 0
order by customer_id;
