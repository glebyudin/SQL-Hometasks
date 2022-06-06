--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".
SELECT film_id, title, special_features 
FROM film 
where special_features @> array['Behind the Scenes'];

--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
SELECT film_id, title, special_features 
FROM film 
where special_features && array['Behind the Scenes'];
------------------------------------------------------------------------------------------
SELECT film_id, title, special_features 
FROM film 
where array_position(special_features, 'Behind the Scenes') is not null

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.
--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

with cte as (select * from inventory i join film f on f.film_id = i.film_id 
and special_features @> array['Behind the Scenes'])
select r.customer_id, count(*)
from rental r 
join cte on r.inventory_id = cte.inventory_id
group by r.customer_id
order by r.customer_id

--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".
--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.
select r.customer_id, count(*)
from rental r 
join (select * from inventory i join film f on f.film_id = i.film_id 
and special_features @> array['Behind the Scenes']) i_f on r.inventory_id = i_f.inventory_id
group by r.customer_id
order by r.customer_id

--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления
create materialized view view_name as
	select r.customer_id, count(*)
	from rental r 
	join (select * from inventory i join film f on f.film_id = i.film_id 
	and special_features @> array['Behind the Scenes']) i_f on r.inventory_id = i_f.inventory_id
	group by r.customer_id
	order by r.customer_id
--with no data
--select * from view_name
refresh materialized view view_name


--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ скорости выполнения запросов
-- из предыдущих заданий и ответьте на вопросы:

--1. Каким оператором или функцией языка SQL, используемых при выполнении домашнего задания, 
--   поиск значения в массиве происходит быстрее
Ответ: одинаково

--Seq Scan on film  (cost=0.00..67.50 rows=536 width=78) (actual time=0.010..0.426 rows=538 loops=1)
explain analyze 
SELECT film_id, title, special_features 
FROM film 
where special_features @> array['Behind the Scenes'];

--Seq Scan on film  (cost=0.00..67.50 rows=536 width=78) (actual time=0.011..0.395 rows=538 loops=1)
explain analyze 
SELECT film_id, title, special_features 
FROM film 
where special_features && array['Behind the Scenes'];

--Seq Scan on film  (cost=0.00..67.50 rows=995 width=78) (actual time=0.012..0.396 rows=538 loops=1)
explain analyze 
SELECT film_id, title, special_features 
FROM film 
where array_position(special_features, 'Behind the Scenes') is not null

--2. какой вариант вычислений работает быстрее: 
--   с использованием CTE или с использованием подзапроса
Ответ: с использованием подзапроса будет быстрее

--Sort  (cost=901.29..902.78 rows=599 width=10) (actual time=10.298..10.325 rows=599 loops=1)
explain analyze 
with cte as (select * from inventory i join film f on f.film_id = i.film_id 
and special_features @> array['Behind the Scenes'])
select r.customer_id, count(*)
from rental r 
join cte on r.inventory_id = cte.inventory_id
group by r.customer_id
order by r.customer_id

--Sort  (cost=673.79..675.29 rows=599 width=10) (actual time=9.710..9.737 rows=599 loops=1)
explain analyze 
select r.customer_id, count(*)
from rental r 
join (select * from inventory i join film f on f.film_id = i.film_id 
and special_features @> array['Behind the Scenes']) i_f on r.inventory_id = i_f.inventory_id
group by r.customer_id
order by r.customer_id


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.





--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день




