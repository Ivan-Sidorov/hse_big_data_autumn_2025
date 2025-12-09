-- 1. Вывести список всех клиентов (таблица customer)
select
	concat(first_name, ' ', last_name) Клиенты
from
	customer;

-- 2. Вывести имена и фамилии клиентов с именем Carolyn.
select
	first_name,
	last_name
from
	customer
where
	first_name = 'Carolyn';

-- 3. Вывести полные имена клиентов (имя + фамилия в одной колонке), у которых имя или фамилия содержат подстроку ary (например: Mary, Geary).
select
	concat(first_name, ' ', last_name) Клиенты
from
	customer
where
	(last_name like '%ary%')
	or
	(first_name like '%ary%');

-- 4. Вывести 20 самых крупных транзакций (таблица payment).
select
	*
from
	payment
order by
	amount desc
limit 20;

-- 5. Вывести адреса всех магазинов, используя подзапрос.
select
	address
from
	address
where
	address_id in (
	select
		address_id
	from
		store
	);

-- 6. Для каждой оплаты вывести число, месяц и день недели в числовом формате (Понедельник – 1, Вторник – 2 и т.д.).
select
	payment_id,
	extract(day from payment_date) as day,
	extract(month from payment_date) as month,
	extract(dow from payment_date) as weekday
from
	payment;

-- 7. Вывести, кто (customer_id), когда (rental_date, приведенная к типу date) и у кого (staff_id) брал диски в аренду в июне 2005 года.
select
	r.rental_id,
	date(rental_date),
	customer_id,
	staff_id
from
	rental r
where
	date_part('year', r.rental_date) = 2005
	and
	date_part('month', r.rental_date) = 6;

-- 8. Вывести название, описание и длительность фильмов (таблица film), выпущенных после 2000 года, с длительностью от 60 до 120 минут включительно. Показать первые 20 фильмов с наибольшей длительностью.
select
	title Название,
	description Описание,
	length Длительность
from
	film
where
	release_year >= 2000
	and
	length between 60 and 120
order by
	length desc
limit 20;

-- 9. Найти все платежи (таблица payment), совершенные в апреле 2007 года, стоимость которых не превышает 4 долларов. Вывести идентификатор платежа, дату (без времени) и сумму платежа. Отсортировать платежи по убыванию суммы, а при равной сумме — по более ранней дате.
select
	payment_id,
	payment_date::date,
	amount
from
	payment
where
	(payment_date between '2007-04-01'
		and '2007-04-30')
	and
	amount <= 4
order by
	amount desc,
	payment_date asc;

-- 10. Показать имена, фамилии и идентификаторы всех клиентов с именами Jack, Bob или Sara, чья фамилия содержит букву «p». Переименовать колонки: с именем — в «Имя», с идентификатором — в «Идентификатор», с фамилией — в «Фамилия». Отсортировать клиентов по возрастанию идентификатора.
select
	first_name as "Имя",
	last_name as "Фамилия",
	customer_id as "Идентификатор"
from
	customer
where
	first_name in ('Jack', 'Bob', 'Sara')
	and
	(last_name like '%p%'
		or last_name like '%P%')
order by
	customer_id asc;

-- 11. Работа с собственной таблицей студентов
-- Создать таблицу студентов с полями: имя, фамилия, возраст, дата рождения и адрес. Все поля должны запрещать внесение пустых значений (NOT NULL).
create table students(
id serial primary key not null,
first_name varchar not null,
last_name varchar not null,
age int not null,
birthdate date not null,
address text not null);

-- Внести в таблицу одного студента с id > 50.
insert
	into
	students(first_name, last_name, age, birthdate, address)
values ('Ivan',
'Ivanov',
21,
'2004-05-05',
'Moscow');
select
	*
from
	students;

-- Внести несколько записей одним запросом, используя автоинкремент id.
insert
	into
	students(first_name, last_name, age, birthdate, address)
values
('Kirill',
'Mironov',
23,
'2002-01-01',
'Kirov'),
('Petr',
'Petrov',
21,
'2004-07-15',
'Saint-Petersburg'),
('Fedor',
'Volkov',
18,
'2007-03-08',
'Krasnoyarsk')
;

-- Удалить одного выбранного студента.
delete
from
	students
where
	id = 1;

-- Удалить таблицу студентов.
drop table students;

-- 12. Вывести количество уникальных имен клиентов.
select
	count(distinct first_name)
from
	customer;

-- 13. Вывести 5 самых часто встречающихся сумм оплаты: саму сумму, даты таких оплат, количество платежей с этой суммой и общую сумму этих платежей.
with cte as
(
select
	payment.amount as amount,
		 count(payment.amount) as most_freq_amount,
		sum(payment.amount) as sum_amount
from
	payment
group by
	payment.amount
)
select
	amount,
	most_freq_amount,
	sum_amount
from
	cte
order by
	most_freq_amount desc
limit 5;

-- 14. Вывести количество ячеек (записей) в инвентаре для каждого магазина.
select
	store_id,
	count(inventory_id) as amount
from
	inventory
group by
	store_id;

-- 15. Вывести адреса всех магазинов, используя соединение таблиц (JOIN).
select
	s.address_id,
	a.address
from
	address a
inner join store s
   on
	s.address_id = a.address_id;

-- 16. Вывести полные имена всех клиентов и всех сотрудников в одну колонку (объединенный список).
select
	c.first_name || ' ' || c.last_name || ' / ' ||
   s.first_name || ' ' || s.last_name as "customer/staff"
from
	customer c
inner join staff s
   on
	s.store_id = c.store_id;

-- 17. Вывести имена клиентов, которые не совпадают ни с одним именем сотрудников (операция EXCEPT или аналог).
select
	first_name
from
	customer
except
   (
select
		first_name
from
	staff);

-- 18. Вывести, кто (customer_id), когда (rental_date, приведенная к типу date) и у кого (staff_id) брал диски в аренду в июне 2005 года.
with cte as (
select
		    rental_date::date,
		    customer_id,
		    staff_id
from
	rental
where
	extract(year from rental_date) = 2005
	and extract(month from rental_date) = 06)
select
	c.first_name || ' ' || c.last_name as customer,
	cte.customer_id,
	cte.rental_date,
	cte.staff_id,
	s.first_name || ' ' || s.last_name as staff
from
	cte
inner join customer c
   on
	cte.customer_id = c.customer_id
inner join staff s
   on
	s.staff_id = cte.staff_id;

-- 19. Вывести идентификаторы всех клиентов, у которых 40 и более оплат. Для каждого такого клиента посчитать средний размер транзакции, округлить его до двух знаков после запятой и вывести в отдельном столбце.
select
	customer_id,
	round(avg(amount), 2) avg_transaction
from
	payment
group by
	customer_id
having
	(count(*) >= 40)
order by
	avg_transaction desc;

-- 20. Вывести идентификатор актера, его полное имя и количество фильмов, в которых он снялся.
with cte as
   (
select
	actor_id,
		count(*) films_count
from
	film_actor
group by
		actor_id)
select
	cte.actor_id,
	a.first_name || ' ' || a.last_name full_name,
	cte.films_count
from
	cte
inner join actor a
   on
	a.actor_id = cte.actor_id;

-- Определить актера, снявшегося в наибольшем количестве фильмов (группировать по id актера).
with cte as
   (
select
	actor_id,
		 count(*) films_count
from
	film_actor
group by
	actor_id
order by
	count(*)
        desc
limit 1
   )
select
	cte.actor_id,
	a.first_name || ' ' || a.last_name full_name,
	cte.films_count
from
	cte
inner join actor a on
	a.actor_id = cte.actor_id
order by
	films_count desc ;

-- 21. Посчитать выручку по каждому месяцу работы проката. Месяц должен определяться по дате аренды (rental_date), а не по дате оплаты (payment_date). Округлить выручку до одного знака после запятой. Отсортировать строки в хронологическом порядке. В отчете должен присутствовать месяц, в который не было выручки (нет данных о платежах).
with cte as
   (
select
		    rental_id,
		    rental_date::date
from
	rental
   )
select
	round(sum(p.amount), 1) revenue,
	extract(year from rental_date) || '-' || extract(month from rental_date) mdate
from
	cte
left join payment p
   on
	p.rental_id = cte.rental_id
group by
	mdate
order by
	mdate;

-- 22. Найти средний платеж по каждому жанру фильма. Отобразить только те жанры, к которым относится более 60 различных фильмов. Округлить средний платеж до двух знаков после запятой и дать понятные названия столбцам. Отсортировать жанры по убыванию среднего платежа.
with cte as (
select
	category_id
from
	film_category
group by
	category_id
having
	count(*) > 60
),
cat as (
select
	f.film_id,
	f.category_id,
	c.name as genre
from
	film_category f
inner join category c on
	c.category_id = f.category_id
where
	f.category_id in (
	select
		category_id
	from
		cte)
)
select
	cat.category_id,
	cat.genre,
	ROUND(AVG(f.rental_rate), 2) as avg_payment
from
	cat
inner join film f on
	f.film_id = cat.film_id
group by
	cat.category_id,
	cat.genre
order by
	avg_payment desc;

-- 23. Определить, какие фильмы чаще всего берут напрокат по субботам. Вывести названия первых 5 самых популярных фильмов. При одинаковой популярности отдать предпочтение фильму, который идет раньше по алфавиту.
with cte as (
select
	inventory_id,
	rental_date
from
	rental
where
	extract(DOW from rental_date) = 6
)
select
	f.title,
	COUNT(*) as counts
from
	cte
inner join inventory i on
	i.inventory_id = cte.inventory_id
inner join film f on
	i.film_id = f.film_id
group by
	f.title
order by
	counts desc,
	f.title asc
limit 5;

-- 24. Для каждой оплаты вывести сумму, дату и день недели (название дня недели текстом).
select
	p.amount,
	p.payment_date,
	to_char(p.payment_date, 'Day') as weekday
from
	payment p
order by
	p.payment_date

-- 25.
-- Распределить фильмы по трем категориям в зависимости от длительности:
-- «Короткие» — менее 70 минут;
-- «Средние» — от 70 минут (включительно) до 130 минут (не включая 130);
-- «Длинные» — от 130 минут и более.
-- Для каждой категории необходимо:
-- посчитать количество прокатов (то есть сколько раз фильмы этой категории брались в аренду);
-- посчитать количество фильмов, которые относятся к этой категории и хотя бы один раз сдавались в прокат.
-- Фильмы, у которых не было ни одного проката, не должны учитываться в подсчете количества фильмов в категории. Продумать, какой тип соединения таблиц нужно использовать, чтобы этого добиться.
select
	case
		when film.length < 70 then 'Короткие'
		when film.length >= 70
		and film.length < 130 then 'Средние'
		else 'Длинные'
	end as film_category,
	count(distinct film.film_id) as films_count,
	count(r.rental_id) as rental_count
from
	film
left join inventory i on
	film.film_id = i.film_id
left join rental r on
	i.inventory_id = r.inventory_id
group by
	film_category
order by
	rental_count desc

-- Для дальнейших заданий считать, что создана таблица weekly_revenue, в которой для каждой недели и года хранится суммарная выручка компании за эту неделю (на основании данных о прокатах и платежах).
create table weekly_revenue as
select
	extract(year from rental_date) as year,
	extract(week from rental_date) as week,
	sum(amount) as revenue
from
	rental r
left join payment p on
	p.rental_id = r.rental_id
group by
	1,
	2
order by
	1,
	2

-- 26. На основе таблицы weekly_revenue рассчитать накопленную (кумулятивную) сумму недельной выручки бизнеса. Вывести все столбцы таблицы weekly_revenue и добавить к ним столбец с накопленной выручкой. Накопленную выручку округлить до целого числа.
select
	year,
	week,
	revenue,
	round(sum(revenue) over (order by year, week), 0) as cumulative_revenue
from
	weekly_revenue

-- 27. На основе таблицы weekly_revenue рассчитать скользящую среднюю недельной выручки, используя для расчета три недели: предыдущую, текущую и следующую. Вывести всю таблицу weekly_revenue и добавить:
-- столбец с накопленной суммой выручки;
-- столбец со скользящей средней недельной выручки.
-- Скользящую среднюю округлить до целого числа.
select
	year,
	week,
	revenue,
	round(sum(revenue) over (order by year, week), 0) as cumulative_revenue,
	round(avg(revenue) over (order by year, week rows between 1 preceding and 1 following), 0) as moving_average
from
	weekly_revenue

-- 28. Рассчитать прирост недельной выручки бизнеса в процентах по сравнению с предыдущей неделей.
-- Прирост в процентах определяется как:
-- (текущая недельная выручка – выручка предыдущей недели) / выручка предыдущей недели × 100%.
-- Вывести всю таблицу weekly_revenue и добавить:
-- ​​​​​​​столбец с накопленной суммой выручки;
-- столбец со скользящей средней;
-- столбец с приростом недельной выручки в процентах.
-- Значение прироста в процентах округлить до двух знаков после запятой.
select
	year,
	week,
	revenue,
	round(sum(revenue) over (order by year, week), 0) as cumulative_revenue,
	round(avg(revenue) over (order by year, week rows between 1 preceding and 1 following), 0) as moving_average,
	round(
      case when lag(revenue, 1) over (order by year, week) = 0 then 0
           else (revenue - lag(revenue, 1) over (order by year, week)) / lag(revenue, 1) over (order by year, week) * 100
      end, 2
      ) as growth_revenue
from
	weekly_revenue
