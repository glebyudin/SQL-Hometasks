--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select concat(first_name,' ',last_name) as customer_name, 
a.address, city.city, country.country
from customer c
inner join address a on c.address_id=a.address_id 
inner join city on a.city_id=city.city_id
inner join country on city.country_id=country.country_id


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select store_id, count(customer_id) as Количество_покупателей
from customer 
group by store_id


--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select store_id, count(customer_id) as Количество_покупателей
from customer 
group by store_id
having count(customer_id) >= 300


-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select c.store_id, count(c.customer_id) as Количество_покупателей,
city.city, concat(staff.first_name,' ',staff.last_name) as ФИО_Продавца
from customer c
join store s on c.store_id = s.store_id
join staff on s.store_id=staff.store_id
join address a on s.address_id=a.address_id
join city on a.city_id=city.city_id
group by c.store_id,city.city, ФИО_Продавца
having count(c.customer_id) >= 300


--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select concat(c.first_name,' ',c.last_name) as ФИО_Покупателя,
count(i.film_id) Количество
from customer c
join rental r on r.customer_id = c.customer_id
join inventory i on r.inventory_id = i.inventory_id
group by ФИО_Покупателя
order by count(i.film_id) DESC
limit 5


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select concat(c.first_name,' ',c.last_name) as ФИО_Покупателя,
count(i.film_id) Количество, round(sum(amount)) Общая_стоимость, 
min(amount), max(amount)
from customer c
join rental r on r.customer_id = c.customer_id
join payment p on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
group by ФИО_Покупателя
order by ФИО_Покупателя


--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
select c1.city, c2.city
from city c1 cross join city c2
where c1.city <> c2.city


--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
select customer_id, round(avg(date(return_date)-date(rental_date)),2)
from rental
--where return_date is not null
group by customer_id


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select f.title, l."name", c."name", t.count, t.sum
from film f
join "language" l on l.language_id = f.language_id
join film_category fc on fc.film_id = f.film_id
join category c on c.category_id = fc.category_id
left join (select i.film_id, count(i.film_id), sum(p.amount)
from inventory i
join rental r on r.inventory_id = i.inventory_id
join payment p on p.rental_id = r.rental_id
group by i.film_id) t on t.film_id = f.film_id


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.





--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".







