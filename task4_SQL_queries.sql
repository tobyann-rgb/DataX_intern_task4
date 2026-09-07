create database if not exists Ecommerce_SQL_Database;
use Ecommerce_SQL_Database;
-- Create and populate Customers table
create table if not exists customers as select distinct
	customer_id,
    first_name,
    last_name,
    gender,
    age_group,
    str_to_date(signup_date, '%Y-%m-%d') as signup_date,
    country
    from raw_ecommerce;
    alter table customers
    modify column customer_id varchar(25) not null;
    alter table customers add primary key (customer_id);
    -- Create and populate products table
    create table if not exists products as select distinct
    product_id,
    product_name,
    category,
    unit_price
    from raw_ecommerce;
    select max(char_length(product_id)) as max_length from products;
    
    alter table products
    modify column product_id varchar(25) not null;
    
    alter table products add primary key (product_id);
    
    -- create and populate Orders table
    create table if not exists orders as select distinct
    order_id,
    customer_id,
    product_id,
    str_to_date(order_date, '%Y-%m-%d') as order_date,
    order_status,
    payment_method,
    quantity
    from raw_ecommerce;
    alter table orders
    modify column order_id varchar(50) not null,
    modify column product_id varchar(25) not null,
    modify column customer_id varchar(25) not null;
    alter table orders
    add primary key (order_id, product_id),
    add constraint fk_orders_customer
		foreign key (customer_id) references customers(customer_id),
	add constraint fk_orders_product
		foreign key (product_id) references products(product_id);
        
-- create and populate reviews table
create table if not exists reviews as select distinct
	review_id,
    order_id,
    rating,
    review_text,
    str_to_date(review_date, '%Y-%m-%d') as review_date
    from raw_ecommerce where review_id is not null;
alter table reviews 
	modify column review_id varchar(25) not null;
    
alter table reviews add primary key (review_id);

-- verify the schema and confirm data was distributed correctly
select 'customers' as tbl, count(*) as total from customers
union all
select 'products', count(*) from products
union all
select 'orders', count(*) from orders
union all
select 'reviews', count(*) from reviews;

-- Task 4 Query set
-- Basic filtering, sorting & grouping 
-- find the total delivered order count and total units sold per payment method
Select
	payment_method,
    count(order_id) as total_orders,
    sum(quantity) as total_units_sold
from orders
where order_status = 'Delivered'
group by payment_method
order by total_units_sold desc;

-- Relational Joins
-- Inner Join, order details & product pricing to calculate revenue per order
select
	o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    o.quantity,
    p.unit_price,
    round(o.quantity * p.unit_price, 2) as line_total
from orders o 
join products p on o.product_id = p.product_id
order by line_total desc limit 10;

-- Left join to identify order counts per customer
select
	c.customer_id,
    c.first_name,
    c.last_name,
    c.country,
    count(o.order_id) as orders_placed
from customers c
left join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.first_name, c.last_name, c.country
order by orders_placed asc limit 10;

-- Right join to check which products receive customer feedback
select
	p.product_name,
    r.review_id,
    r.rating,
    r.review_text
from reviews r 
right join orders o 
	on r.order_id = o.order_id
join products p
	on o.product_id = p.product_id
where r.rating = 1 limit 10;

-- nested subqueries to find customers who spent more than the average order value
Select
	customer_id,
    order_id,
    order_date,
    quantity
from orders
Where quantity > (
	select avg(quantity)
    from orders)
order by quantity desc limit 10;

-- summary aggregations & average revenue per user, calculate platform-wide totals
select
	count(distinct c.customer_id) as total_customers,
    count(o.order_id) as total_orders,
    round(sum(o.quantity * p.unit_price), 2) as total_revenue,
    round(avg(o.quantity * p.unit_price), 2) as avg_order_value,
-- ARPU = total_revenue/total unique users
	round(sum(o.quantity * p.unit_price) / count(distinct c.customer_id), 2) as arpu
from customers c 
join orders o on c.customer_id = o.customer_id
join products p on o.product_id = p.product_id;
		
-- View for modular reporting; create a reusable view
create or replace view vw_customer_order_summary as
select
	c.customer_id,
    concat(c.first_name, ' ', c.last_name) as full_name,
    c.country,
    c.age_group,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    o.quantity,
	round(o.quantity * p.unit_price, 2) as total_price, 
    r.rating
from customers c 
join orders o on c.customer_id = o.customer_id
join products p on o.product_id = p.product_id
left join reviews r on o.order_id = r.order_id;
-- Query the view
select * from vw_customer_order_summary limit 10;

-- add targeted indexes on high-traffic filtering and join columns
-- index on order lookup dates
create index idx_orders_order_date on orders(order_date);
-- index on customer country for demographic filtering
alter table customers
	modify column country varchar(50) not null;
create index idx_customers_country on customers(country);
-- verify index creation
show index from orders;
show index from customers;

    
    
    