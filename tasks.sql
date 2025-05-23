-- Задание 5
-- Вывести количество рейсов, совершенных на TU-134

select COUNT(*) as count from Trip WHERE plane = 'TU-134'

-- Задание 6
-- Какие компании совершали перелеты на Boeing

SELECT DISTINCT c.name 
FROM Trip t 
JOIN company c on t.company = c.id
WHERE t.plane = 'Boeing'

-- Задание 7
-- Вывести все названия самолётов, на которых можно улететь в Москву (Moscow)

select DISTINCT plane FROM Trip WHERE town_to = "Moscow"

-- Задание 8
-- В какие города можно улететь из Парижа (Paris) и сколько времени это займёт?

SELECT town_to,
  TIMEDIFF(time_in, time_out) AS flight_time
FROM Trip
WHERE town_from = "Paris"

-- Задание 9
-- Какие компании организуют перелеты из Владивостока (Vladivostok)?

SELECT DISTINCT c.name
FROM Trip t
	JOIN company c ON t.company = c.id
WHERE t.town_from = 'Vladivostok'


-- Задание 10
-- Вывести вылеты, совершенные с 10 ч. по 14 ч. 1 января 1900 г.

SELECT * FROM Trip
WHERE time_out BETWEEN '1900-01-01T10:00:00.000Z' AND '1900-01-01T14:00:00.000Z'


-- Задание 11
-- Выведите пассажиров с самым длинным ФИО. Пробелы, дефисы и точки считаются частью имени.
SELECT name FROM Passenger
WHERE LENGTH(name) = (
	SELECT MAX(LENGTH(name))
	FROM Passenger
);

-- Задание 12
-- Выведите идентификаторы всех рейсов и количество пассажиров на них. Обратите внимание, что на каких-то рейсах пассажиров может не быть. В этом случае выведите число "0".

SELECT t.id AS id,
	COUNT(p.passenger) AS COUNT
FROM Trip t
	LEFT JOIN Pass_in_trip p ON t.id = p.trip
GROUP BY t.id
ORDER BY t.id;

-- Задание 12
-- Вывести имена людей, у которых есть полный тёзка среди пассажиров
SELECT name FROM Passenger
GROUP BY name HAVING COUNT(*) >= 2;

-- Задание 14
-- В какие города летал Bruce Willis

SELECT town_to from Trip t 
JOIN Pass_in_trip pt on t.id = pt.trip
JOIN Passenger p on pt.passenger = p.id
WHERE p.name = 'Bruce Willis'

-- Задание 15
-- Выведите идентификатор пассажира Стив Мартин (Steve Martin) и дату и время его прилёта в Лондон (London)

SELECT p.id, t.time_in from Passenger p
JOIN Pass_in_trip pt on p.id = pt.passenger
JOIN Trip t ON pt.trip = t.id
WHERE p.name = 'Steve Martin' AND t.town_to = 'London';

-- Задание 16
-- Вывести отсортированный по количеству перелетов (по убыванию) и имени (по возрастанию) список пассажиров, совершивших хотя бы 1 полет.

SELECT p.name, COUNT(*) AS COUNT
FROM Passenger p
	JOIN Pass_in_trip pt ON p.id = pt.passenger
GROUP BY p.id, p.name
HAVING COUNT(*) >= 1
ORDER BY COUNT DESC, p.name ASC;

-- Задание 17
-- Определить, сколько потратил в 2005 году каждый из членов семьи. В результирующей выборке не выводите тех членов семьи, которые ничего не потратили.

SELECT fm.member_name, fm.status,
	SUM(p.amount * p.unit_price) AS costs
FROM FamilyMembers fm
	JOIN Payments p ON p.family_member = fm.member_id
WHERE YEAR(p.date) = 2005
GROUP BY fm.member_name, fm.status
HAVING costs > 0
ORDER BY costs DESC;

-- Задание 18
-- Выведите имя самого старшего человека. Если таких несколько, то выведите их всех.

SELECT member_name FROM FamilyMembers
WHERE birthday = (SELECT MIN(birthday) FROM FamilyMembers);


-- Задание 19
-- Определить, кто из членов семьи покупал картошку (potato)

SELECT DISTINCT fm.status FROM FamilyMembers fm
JOIN Payments p ON p.family_member = fm.member_id
JOIN Goods g on g.good_id = p.good
WHERE g.good_name = 'potato'

-- Задание 20
-- Сколько и кто из семьи потратил на развлечения (entertainment). Вывести статус в семье, имя, сумму

SELECT fm.status, fm.member_name, SUM(p.amount * p.unit_price) AS costs 
FROM FamilyMembers fm
JOIN Payments p ON p.family_member = fm.member_id
JOIN Goods g ON g.good_id = p.good
JOIN GoodTypes gt ON gt.good_type_id = g.type
WHERE gt.good_type_name = 'entertainment'
GROUP BY fm.status, fm.member_name
HAVING costs > 0;

-- Задание 21
-- Определить товары, которые покупали более 1 раза

SELECT g.good_name FROM Payments p
JOIN Goods g ON p.good = g.good_id
GROUP BY g.good_name
HAVING COUNT(p.payment_id) > 1;

-- Задание 22
-- Найти имена всех матерей (mother)

SELECT DISTINCT member_name FROM FamilyMembers
WHERE STATUS = 'mother'

-- Задание 23
-- Найдите самый дорогой деликатес (delicacies) и выведите его цену

SELECT g.good_name, p.unit_price FROM Payments p
JOIN Goods g on p.good = g.good_id
JOIN GoodTypes gt ON g.type = gt.good_type_id
WHERE gt.good_type_name = 'delicacies'
ORDER BY p.unit_price DESC
LIMIT 1;

-- Задание 24
-- Определить кто и сколько потратил в июне 2005

SELECT fm.member_name,
  SUM(p.amount * p.unit_price) AS costs
FROM FamilyMembers fm
JOIN Payments p ON fm.member_id = p.family_member
WHERE YEAR(p.date) = 2005 AND MONTH(p.date) = 6
GROUP BY fm.member_name
HAVING costs > 0
ORDER BY costs DESC;

-- Задание 25
-- Определить, какие товары не покупались в 2005 году

SELECT g.good_name
FROM Goods g
WHERE NOT EXISTS (
	SELECT 1 FROM Payments p
	WHERE YEAR(p.date) = 2005 AND p.good = g.good_id);

-- или

SELECT g.good_name FROM Goods g
LEFT JOIN (
	SELECT DISTINCT good FROM Payments
	WHERE YEAR(date) = 2005
) p ON g.good_id = p.good
WHERE p.good IS NULL;

-- Задание 26
-- Определить группы товаров, которые не приобретались в 2005 году

SELECT gt.good_type_name
FROM GoodTypes gt
WHERE NOT EXISTS (
	SELECT 1
	FROM Payments p
	JOIN Goods g ON p.good = g.good_id
	WHERE YEAR(p.date) = 2005 AND g.type = gt.good_type_id
);

-- Задание 27
-- Узнайте, сколько было потрачено на каждую из групп товаров в 2005 году. Выведите название группы и потраченную на неё сумму. Если потраченная сумма равна нулю, т.е. товары из этой группы не покупались в 2005 году, то не выводите её.

SELECT gt.good_type_name,
	SUM(p.amount * p.unit_price) AS costs
FROM Payments p
	JOIN Goods g ON p.good = g.good_id
	JOIN GoodTypes gt ON g.type = gt.good_type_id
WHERE YEAR(p.date) = 2005
GROUP BY gt.good_type_name
HAVING costs > 0
ORDER BY costs DESC;


-- Задание 28
-- Сколько рейсов совершили авиакомпании из Ростова (Rostov) в Москву (Moscow) ?

SELECT COUNT(*) as count FROM Trip
WHERE town_from = 'Rostov' AND town_to = 'Moscow'


-- Задание 29
-- Выведите имена пассажиров улетевших в Москву (Moscow) на самолете TU-134. В ответе не должно быть дубликатов.

SELECT DISTINCT p.name from Passenger p
JOIN Pass_in_trip pt ON p.id = pt.passenger
JOIN Trip t ON pt.trip = t.id
WHERE t.plane = 'TU-134' AND t.town_to = 'Moscow'

-- Задание 30
-- Выведите нагруженность (число пассажиров) каждого рейса (trip). Результат вывести в отсортированном виде по убыванию нагруженности.

