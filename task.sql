-- Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT a.model, fare_conditions, count(seat_no) FROM aircrafts a
LEFT JOIN seats s
USING (aircraft_code)
GROUP by (a.model, s.aircraft_code, fare_conditions)
ORDER BY a.model

-- Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT a.model, count(seat_no) qt FROM aircrafts a
LEFT JOIN seats s
USING (aircraft_code)
GROUP BY (a.model, s.aircraft_code)
ORDER BY qt DESC LIMIT 3

-- Вывести код, модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам
SELECT a.model, a.aircraft_code, s.seat_no FROM aircrafts a
LEFT JOIN seats s
USING (aircraft_code)
WHERE a.model= 'Аэробус A321-200' AND fare_conditions <> 'Economy'
ORDER BY seat_no

-- Вывести города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город)
SELECT airport_code, airport_name, city FROM airports
WHERE city IN (
SELECT city FROM airports
GROUP BY city
HAVING count(city) > 1)

-- Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT (scheduled_departure - bookings.now()) time_rest_to_flight, flight_id FROM flights_v
WHERE departure_city = 'Екатеринбург' AND arrival_city = 'Москва'
AND (scheduled_departure - interval '15 minute' > bookings.now())
ORDER BY (scheduled_departure - bookings.now()) LIMIT 1

-- Вывести самый дешевый и дорогой билет и стоимость ( в одном результирующем ответе)
В1:
SELECT amount, ticket_no FROM ticket_flights
WHERE amount  = (SELECT min(amount) FROM ticket_flights)
 OR amount  = (SELECT max(amount) FROM ticket_flights)
В2:
(SELECT amount, ticket_no FROM ticket_flights
WHERE amount = (SELECT min(amount) FROM ticket_flights)
LIMIT 1)
UNION
(SELECT amount, ticket_no FROM ticket_flights
WHERE amount = (SELECT max(amount) FROM ticket_flights)
LIMIT 1) 

-- Вывести информацию о вылете с наибольшей суммарной стоимостью билетов
SELECT sum(amount), flight_id FROM ticket_flights
GROUP BY flight_id
ORDER BY sum(amount) DESC LIMIT 1

-- Найти модель самолета, принесшую наибольшую прибыль (наибольшая суммарная стоимость билетов). Вывести код модели, информацию о модели и общую стоимость
WITH t AS (SELECT flight_id, sum(amount) volume FROM ticket_flights
GROUP BY flight_id
ORDER BY sum(amount) DESC LIMIT 1)
SELECT aircraft_code, model, range, t.volume FROM aircrafts ar 
INNER JOIN flights fl
USING (aircraft_code)
INNER JOIN t
ON fl.flight_id = t.flight_id

-- Найти самый частый аэропорт назначения для каждой модели самолета. Вывести количество вылетов, информацию о модели самолета, аэропорт назначения, город
WITH t AS (
SELECT count(arrival_airport) qt, arrival_airport, aircraft_code FROM flights_v
GROUP BY aircraft_code, arrival_airport)
SELECT t.qt, t.aircraft_code, aircrafts.model, t.arrival_airport, airports.city, airports.airport_name FROM t
INNER JOIN (select max(t.qt) max_qt, aircraft_code plane from t
              group by aircraft_code) maximum			  
ON (t.qt = maximum.max_qt and t.aircraft_code = maximum.plane)
INNER JOIN aircrafts
USING (aircraft_code)
INNER JOIN airports 
ON airports.airport_code = t.arrival_airport