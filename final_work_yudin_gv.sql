--=============== ИТОГОВАЯ РАБОТА =======================================
--Юдин Глеб В.


--Задание 1
--В каких городах больше одного аэропорта?

--Выбираю города из таблицы аэропорты, группирую аэропорты по городу, вывожу количество городов-city, которых больше одного.
select city from airports
group by city
having count(city) >1


--Задание 2
--В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?

--Выбираю "Аэропорт отправления" из таблицы "Рейсы", которую объединяю с таблицей "Воздушные судна" по полю "код самолета"
--дальше задаю условие, где дальность полета является максимальной, подзапросом у меня является запрос дальности полета с использованием агрегатной функции,
--далее группирую по полю "Аэропорт отправления"
select flights.departure_airport
from aircrafts_data ad
join flights on ad.aircraft_code=flights.aircraft_code  
where ad.range = (select max(range) from aircrafts_data )
group by (flights.departure_airport)


--Задание 3
--Вывести 10 рейсов с максимальным временем задержки вылета

--Выбираю flight number, а также выбираю и рассчитываю время максимальной задержки – разница между фактическим временем и временем по графику, 
--сортирую от большего к меньшему и вывожу только 10 рейсов.
--реальное время вылета должно быть отличное от значения Null 
select flight_no, (actual_departure - scheduled_departure) as "макс_вр_задержки"
from flights
where actual_departure is not null 
order by "макс_вр_задержки" desc
limit 10;

--Задание 4
--Были ли брони, по которым не были получены посадочные талоны?

--Выбираем номер брони из таблицы tickets
--Использую left join для определения всего множества броней 'is null', джойню таблицу boarding_passes - Посадочный талон по номеру билета
select count(t.book_ref)
from tickets t 
left join boarding_passes bp on t.ticket_no = bp.ticket_no
where boarding_no is null
--Ответ: были, количество = 127,899


--Задание 5
--Найдите количество свободных мест для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
--Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах в течении дня.



--Задание 6
--Найдите процентное соотношение перелетов по типам самолетов от общего количества.

--Выбираем код самолета, а дальше формируем столбец, где округляем и высчитываем процентное отношение количества самолетов одного и того же типа к общему количеству
--Также применяем подзапрос, в котором выводим количество полетов модели
explain analyze 
select aircraft_code, --коды
round(cast(count(flight_id) as decimal) / (select count(flight_id) from flights)*100,2) as "%" --делим количество перелетов каждого самолета на общее (использ. тип данных decimal)
from flights --выбираем из таблицы перелеты
group by aircraft_code --группируем выборку



--Задание 7
--Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?

-- Создаем общие табличные выражения с запрос с максимальной стоимостью билета класса обслуживания 'Economy'
-- и с запрос с минимальной стоимостью билета класса обслуживания 'Business'
-- Использую join для объединения запросов по flight_id 
-- задаю условие, где минимальная стоимость билета бизнес-класса меньше максимальной стоимости билета эконом-класса 
with 
cte1 as (select flight_id, max(amount) as max_economy
	from ticket_flights
	where fare_conditions = 'Economy'
	group by flight_id
	order by flight_id), 
cte2 as (select flight_id, min(amount) as min_business
	from ticket_flights
	where fare_conditions = 'Business'
	group by flight_id
	order by flight_id)
select distinct a.city, cte1.max_economy, cte2.min_business
from cte1 
join cte2 on cte1.flight_id = cte2.flight_id and cte1.max_economy > cte2.min_business
join flights f on cte2.flight_id = f.flight_id 
join airports a on f.arrival_airport = a.airport_code 
--Ответ: не было


--Задание 8
--Между какими городами нет прямых рейсов?

--Использую декартовое произведение и получаю пары город отправления и город прилета из таблицы airports 
--Использую cross join и оператор except

select distinct a1.city, a2.city 
from airports a1 
cross join airports a2 
where a1.city <> a2.city
except
select departure_city, arrival_city
from routes


--Задание 9
--Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы*

select distinct f.departure_airport, f.arrival_airport,
acos(sind(latitude_a)*sind(latitude_b)+cosd(latitude_a)*cosd(latitude_b)*cosd(longitude_a - longitude_b)) as d,
d*6371 as l,
from flight
--дальше надо использовать case
--join