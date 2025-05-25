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

SELECT trip, COUNT(*) AS count FROM Pass_in_trip
GROUP BY trip
ORDER BY count DESC;

-- Задание 31
-- Вывести всех членов семьи с фамилией Quincey.

SELECT * from FamilyMembers
WHERE member_name LIKE '% Quincey'

-- Задание 32
-- Вывести средний возраст людей (в годах), хранящихся в базе данных. Результат округлите до целого в меньшую сторону.

SELECT FLOOR(AVG(TIMESTAMPDIFF(YEAR, birthday, CURDATE()))) AS age
FROM FamilyMembers;

-- Задание 33
-- Найдите среднюю цену икры на основе данных, хранящихся в таблице Payments. В базе данных хранятся данные о покупках красной (red caviar) и черной икры (black caviar). В ответе должна быть одна строка со средней ценой всей купленной когда-либо икры.

SELECT AVG(unit_price) AS cost
FROM Payments
WHERE good IN (5, 7);

-- Задание 34
-- Сколько всего 10-ых классов

SELECT COUNT(*) AS count FROM Class
WHERE name LIKE '10%';

-- Задание 35
-- Сколько различных кабинетов школы использовались 2 сентября 2019 года для проведения занятий?

SELECT COUNT(DISTINCT classroom) AS count
FROM Schedule
WHERE date = '2019-09-02';

-- Задание 36
-- Выведите информацию об обучающихся живущих на улице Пушкина (ul. Pushkina)?

SELECT * FROM Student
WHERE address LIKE 'ul. Pushkina%'

-- Задание 37
-- Сколько лет самому молодому обучающемуся ?
SELECT TIMESTAMPDIFF(YEAR, MAX(birthday), CURDATE()) AS year
FROM Student;

-- Задание 38
-- Сколько Анн (Anna) учится в школе ?

SELECT COUNT(*) AS count FROM Student
WHERE first_name = 'Anna'

-- Задание 39
-- Сколько обучающихся в 10 B классе ?

SELECT COUNT(*) AS count 
FROM Student_in_class sc
JOIN Class c ON sc.class = c.id
WHERE c.name = '10 B'

-- Задание 40
-- Выведите название предметов, которые преподает Ромашкин П.П. (Romashkin P.P.). Обратите внимание, что в базе данных есть несколько учителей с такой фамилией.

SELECT s.name as subjects FROM Subject s
JOIN Schedule sc on s.id = sc.subject
WHERE sc.teacher = 1

-- Задание 41
-- Выясните, во сколько по расписанию начинается четвёртое занятие.

SELECT start_pair FROM Timepair 
WHERE id = 4

-- Задание 42
-- Сколько времени обучающийся будет находиться в школе, учась со 2-го по 4-ый уч. предмет?

SELECT 
	TIMEDIFF(
		(SELECT end_pair FROM Timepair WHERE id = 4),
		(SELECT start_pair FROM Timepair WHERE id = 2)
	) AS time;

-- Задание 43
-- Выведите фамилии преподавателей, которые ведут физическую культуру (Physical Culture). Отсортируйте преподавателей по фамилии в алфавитном порядке.

SELECT t.last_name
FROM Teacher t
	JOIN Schedule s ON t.id = s.teacher
	JOIN Subject sub ON s.subject = sub.id
WHERE sub.name = 'Physical Culture'
GROUP BY t.last_name
ORDER BY t.last_name ASC;

-- Задание 44
-- Найдите максимальный возраст (количество лет) среди обучающихся 10 классов на сегодняшний день. Для получения текущих даты и времени используйте функцию NOW().

SELECT TIMESTAMPDIFF(YEAR, s.birthday, NOW()) AS max_year 
FROM Student s 
	JOIN Student_in_class sc ON s.id = sc.student
	JOIN Class c ON sc.class = c.id
WHERE c.name LIKE '10%'
ORDER BY max_year  DESC
LIMIT 1;

-- Задание 45
-- Какие кабинеты чаще всего использовались для проведения занятий? Выведите те, которые использовались максимальное количество раз.

SELECT classroom
FROM (
	SELECT classroom, COUNT(*) AS cnt FROM Schedule
	GROUP BY classroom
	) AS usage_count
WHERE cnt = (
	SELECT MAX(cnt) FROM (
		SELECT COUNT(*) AS cnt FROM Schedule
		GROUP BY classroom
	) AS max_usage);

-- Задание 46
-- В каких классах введет занятия преподаватель "Krauze" ?

SELECT DISTINCT c.name from Class c 
JOIN Schedule s on c.id = s.class
JOIN Teacher t ON s.teacher = t.id
WHERE t.last_name = 'Krauze'

-- Задание 47
-- Сколько занятий провел Krauze 30 августа 2019 г.?
SELECT COUNT(*) AS COUNT
FROM Schedule s
	JOIN Teacher t ON s.teacher = t.id
WHERE t.last_name = 'Krauze' AND s.date = '2019-08-30';

-- Задание 48
-- Выведите заполненность классов в порядке убывания

SELECT DISTINCT c.name,
	COUNT(*) AS COUNT
FROM Class c
	JOIN Student_in_class s ON c.id = s.class
GROUP BY c.name
ORDER BY COUNT DESC;

-- Задание 49
-- Какой процент обучающихся учится в "10 A" классе? Выведите ответ в диапазоне от 0 до 100 с округлением до четырёх знаков после запятой, например, 96.0201.

SELECT ROUND(
	100.0 * (
		SELECT COUNT(*) FROM Student_in_class
		WHERE class = 7) / 
		(SELECT COUNT(*) FROM Student_in_class), 4) AS percent

-- Задание 50
-- Какой процент обучающихся родился в 2000 году? Результат округлить до целого в меньшую сторону.

SELECT TRUNCATE(
	100.0 * (
		SELECT COUNT(*) FROM Student
		WHERE YEAR(birthday) = 2000) / 
		(SELECT COUNT(*) FROM Student), 0) AS percent

-- Задание 51
-- Добавьте товар с именем "Cheese" и типом "food" в список товаров (Goods).

INSERT INTO Goods (good_id, good_name, type)
VALUES (19, 'Cheese', 2);

-- Задание 52
-- Добавьте в список типов товаров (GoodTypes) новый тип "auto".

INSERT INTO GoodTypes (good_type_id, good_type_name)
VALUES (9, 'auto');

-- Задание 53
-- Измените имя "Andie Quincey" на новое "Andie Anthony".

UPDATE FamilyMembers
SET member_name = 'Andie Anthony'
WHERE member_name = 'Andie Quincey';


-- Задание 54
-- Удалить всех членов семьи с фамилией "Quincey".

DELETE FROM FamilyMembers
WHERE member_name LIKE '% Quincey';

-- Задание 55
-- Удалить компании, совершившие наименьшее количество рейсов.

DELETE c
FROM company c
JOIN (
	SELECT company FROM Trip
	GROUP BY company
	HAVING COUNT(*) = ( SELECT MIN(cnt)
		FROM (
			SELECT COUNT(*) AS cnt FROM Trip
			GROUP BY company
		) AS x)
) AS t ON c.id = t.company;

-- Задание 56
-- Удалить все перелеты, совершенные из Москвы (Moscow).

DELETE FROM Trip
WHERE town_from = 'Moscow'


-- Задание 57
-- Перенести расписание всех занятий на 30 мин. вперед.

UPDATE Timepair
SET start_pair = DATE_ADD(start_pair, INTERVAL 30 MINUTE),
	end_pair = DATE_ADD(end_pair, INTERVAL 30 MINUTE);

-- Задание 59
-- Вывести пользователей,указавших Белорусский номер телефона ? Телефонный код Белоруссии +375.

SELECT * FROM Users
WHERE phone_number LIKE '+375%'

-- Задание 60
-- Выведите идентификаторы преподавателей, которые хотя бы один раз за всё время преподавали в каждом из одиннадцатых классов.

SELECT teacher FROM Schedule s
JOIN Class c ON s.class = c.id
WHERE c.name LIKE '11%'
GROUP BY teacher
HAVING COUNT(DISTINCT c.id) = (
    SELECT COUNT(*) FROM Class WHERE name LIKE '11%'
);