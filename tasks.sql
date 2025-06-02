-- Задание 1
-- Вывести имена всех людей, которые есть в базе данных авиакомпаний

select name FROM Passenger

-- Задание 2
-- Вывести названия всеx авиакомпаний

select name FROM Company


-- Задание 3
-- Вывести все рейсы, совершенные из Москвы

select * from Trip WHERE town_from = "Moscow"

-- Задание 4
-- Вывести имена людей, которые заканчиваются на "man"

select name FROM Passenger where name LIKE '%man'

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

-- Задание 61
-- Выведите список комнат, которые были зарезервированы хотя бы на одни сутки в 12-ую неделю 2020 года. В данной задаче в качестве одной недели примите период из семи дней, первый из которых начинается 1 января 2020 года. Например, первая неделя года — 1–7 января, а третья — 15–21 января.

SELECT DISTINCT r.* FROM Rooms r
JOIN Reservations res ON r.id = res.room_id
WHERE DATE(res.start_date) <= '2020-03-23'
  AND DATE(res.end_date) >= '2020-03-17';

-- Задание 62
-- Вывести в порядке убывания популярности доменные имена 2-го уровня, используемые пользователями для электронной почты. Полученный результат необходимо дополнительно отсортировать по возрастанию названий доменных имён.

SELECT 
	SUBSTRING_INDEX(email, '@', -1) AS domain,
	COUNT(*) AS count
FROM Users
GROUP BY domain
ORDER BY count DESC, domain ASC;

-- Задание 63
-- Выведите отсортированный список (по возрастанию) фамилий и имен студентов в виде Фамилия.И.

SELECT CONCAT(last_name, '.', LEFT(first_name, 1), '.') AS name
FROM Student
ORDER BY last_name ASC, first_name ASC;

-- Задание 64
-- Вывести количество бронирований по каждому месяцу каждого года, в которых было хотя бы 1 бронирование. Результат отсортируйте в порядке возрастания даты бронирования.

SELECT 
	YEAR(start_date) AS year,
	MONTH(start_date) AS month,
	COUNT(*) AS amount
FROM Reservations
GROUP BY year, month
ORDER BY year ASC, month ASC;

-- Задание 65
-- Необходимо вывести рейтинг для комнат, которые хоть раз арендовали, как среднее значение рейтинга отзывов округленное до целого вниз.

SELECT res.room_id,
	FLOOR(AVG(rating)) AS rating
FROM Reservations res
	JOIN Reviews r ON res.id = r.reservation_id
GROUP BY room_id
ORDER BY room_id;

-- Задание 66
-- Вывести список комнат со всеми удобствами (наличие ТВ, интернета, кухни и кондиционера), а также общее количество дней и сумму за все дни аренды каждой из таких комнат.

SELECT
	r.home_type,
	r.address,
	COALESCE(SUM(DATEDIFF(res.end_date, res.start_date)), 0) AS days,
	COALESCE(SUM(res.total), 0) AS total_fee
FROM Rooms r
LEFT JOIN Reservations res ON r.id = res.room_id
WHERE r.has_tv = 1
  AND r.has_internet = 1
  AND r.has_kitchen = 1
  AND r.has_air_con = 1
GROUP BY r.home_type, r.address

-- Задание 67
-- Вывести время отлета и время прилета для каждого перелета в формате "ЧЧ:ММ, ДД.ММ - ЧЧ:ММ, ДД.ММ", где часы и минуты с ведущим нулем, а день и месяц без.

SELECT CONCAT(
	DATE_FORMAT(time_out, "%H:%i, %e.%c"),
	" - ",
	DATE_FORMAT(time_in, "%H:%i, %e.%c")
) AS flight_time
FROM Trip

-- Задание 68
-- Для каждой комнаты, которую снимали как минимум 1 раз, найдите имя человека, снимавшего ее последний раз, и дату, когда он выехал

SELECT res.room_id, u.name, res.end_date from Rooms r
JOIN Reservations res ON r.id = res.room_id
JOIN Users u ON res.user_id = u.id
WHERE end_date = (
	SELECT MAX(end_date) FROM Reservations res2
	WHERE res2.room_id = res.room_id
)


-- Задание 69
-- Вывести идентификаторы всех владельцев комнат, что размещены на сервисе бронирования жилья и сумму, которую они заработали

SELECT r.owner_id, COALESCE(SUM(res.total), 0) as total_earn FROM Rooms r
LEFT JOIN Reservations res on r.id = res.room_id
GROUP BY r.owner_id

-- Задание 70
-- Необходимо категоризовать жилье на economy, comfort, premium по цене соответственно <= 100, 100 < цена < 200, >= 200. В качестве результата вывести таблицу с названием категории и количеством жилья, попадающего в данную категорию

SELECT CASE
		WHEN price <= 100 THEN "economy"
		WHEN price > 100
		AND price < 200 THEN "comfort"
		WHEN price >= 200 THEN "premium"
	END AS category,
	COUNT(1) AS COUNT
FROM Rooms
GROUP BY category

-- Задание 71
-- Найдите какой процент пользователей, зарегистрированных на сервисе бронирования, хоть раз арендовали или сдавали в аренду жилье. Результат округлите до сотых.

SELECT ROUND((
		SELECT COUNT(DISTINCT u.id)
		FROM Users u,
			Rooms r,
			Reservations res
		WHERE u.id = res.user_id
			OR (
				u.id = r.owner_id
				AND r.id = res.room_id
			)
	) / (
		SELECT COUNT(1)
		FROM Users
	) * 100,
	2
) AS percent

-- Задание 72
-- Выведите среднюю цену бронирования за сутки для каждой из комнат, которую бронировали хотя бы один раз. Среднюю цену необходимо округлить до целого значения вверх.

SELECT room_id,
	CEILING(SUM(res.price) / COUNT(1)) AS avg_price
FROM Rooms r
	JOIN Reservations res ON r.id = res.room_id
GROUP BY room_id

-- Задание 73
-- Выведите id тех комнат, которые арендовали нечетное количество раз

SELECT room_id,
	COUNT(1) AS COUNT
FROM Rooms r
	JOIN Reservations res ON r.id = res.room_id
GROUP BY room_id
HAVING COUNT(1) %2 = 1

-- Задание 74
-- Выведите идентификатор и признак наличия интернета в помещении. Если интернет в сдаваемом жилье присутствует, то выведите «YES», иначе «NO».

SELECT id,
	CASE
		WHEN has_internet = 1 THEN "YES"
		WHEN has_internet = 0 THEN "NO"
	END AS has_internet
FROM Rooms
GROUP BY id

-- Задание 75
-- Выведите фамилию, имя и дату рождения студентов, кто был рожден в мае.

SELECT last_name, first_name, birthday FROM Student
WHERE MONTH(birthday) = 5

-- Задание 76
-- Вывести имена всех пользователей сервиса бронирования жилья, а также два признака: является ли пользователь собственником какого-либо жилья (is_owner) и является ли пользователь арендатором (is_tenant). В случае наличия у пользователя признака необходимо вывести в соответствующее поле 1, иначе 0.

SELECT
    u.name,
    CASE WHEN r.owner_id IS NOT NULL THEN 1 ELSE 0 END AS is_owner,
    CASE WHEN res.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_tenant
FROM Users u
LEFT JOIN (SELECT DISTINCT owner_id FROM Rooms) r ON u.id = r.owner_id
LEFT JOIN (SELECT DISTINCT user_idFROM Reservations) res ON u.id = res.user_id
ORDER BY u.name;

-- Задание 77
-- Создайте представление с именем "People", которое будет содержать список имен (first_name) и фамилий (last_name) всех студентов (Student) и преподавателей(Teacher)

CREATE VIEW People AS 
SELECT first_name, last_name from Student 
UNION
SELECT first_name, last_name from Teacher

-- Задание 78
-- Выведите всех пользователей с электронной почтой в «hotmail.com»

select * from Users
WHERE email LIKE '%@hotmail.com'

-- Задание 79
-- Выведите поля id, home_type, price у всего жилья из таблицы Rooms. Если комната имеет телевизор и интернет одновременно, то в качестве цены в поле price выведите цену, применив скидку 10%.

SELECT id, home_type,
	CASE
		WHEN has_tv = 1 AND has_internet = 1 THEN price * 0.9
		ELSE price
	END AS price
FROM Rooms

-- Задание 80
-- Создайте представление «Verified_Users» с полями id, name и email, которое будет показывает только тех пользователей, у которых подтвержден адрес электронной почты.

CREATE VIEW Verified_Users AS 
SELECT id, name, email from Users
WHERE email_verified_at	IS NOT NULL

-- Задание 93
-- Какой средний возраст клиентов, купивших Smartwatch (использовать наименование товара product.name) в 2024 году?

SELECT AVG(age) AS average_age
FROM Customer
WHERE customer_key IN (
	SELECT DISTINCT customer_key
	FROM Purchase
	WHERE product_key = 6 AND YEAR(date) = 2024
);

-- Задание 94
-- Вывести имена покупателей, каждый из которых приобрёл Laptop и Monitor (использовать наименование товара product.name) в марте 2024 года?

SELECT c.name
FROM Customer c
JOIN Purchase p ON c.customer_key = p.customer_key
JOIN Product pr ON p.product_key = pr.product_key
WHERE pr.name IN ('Laptop', 'Monitor')
  AND YEAR(p.date) = 2024
  AND MONTH(p.date) = 3
GROUP BY c.customer_key, c.name
HAVING COUNT(DISTINCT pr.name) = 2; --Используем, чтобы выбрать только тех, кто купил оба этих товара

-- Задание 97
-- Посчитать количество работающих складов на текущую дату по каждому городу. Вывести только те города, у которых количество складов более 80. Данные на выходе - город, количество складов.

SELECT city, COUNT(*) AS warehouse_count FROM warehouses
WHERE date_close IS NULL
GROUP BY city
HAVING COUNT(*) > 80;

-- Задание 99
-- Посчитай доход с женской аудитории (доход = сумма(price * items)). Обратите внимание, что в таблице женская аудитория имеет поле user_gender «female» или «f».

SELECT SUM(price * items) as income_from_female from Purchases
WHERE user_gender IN ('female', 'f');

-- Задание 101
-- Выведи для каждого пользователя первое наименование, которое он заказал (первое по времени транзакции).


SELECT t.user_id, t.item
FROM Transactions t
WHERE t.transaction_ts = (
	SELECT MIN(t2.transaction_ts)
	FROM Transactions t2
	WHERE t2.user_id = t.user_id
);

-- или

SELECT t1.user_id, t1.item
FROM Transactions t1
LEFT JOIN Transactions t2
	ON t1.user_id = t2.user_id
	AND t1.transaction_ts > t2.transaction_ts
WHERE t2.user_id IS NULL;

-- Задание 103
-- Вывести список имён сотрудников, получающих большую заработную плату, чем у непосредственного руководителя.

SELECT e.name
FROM Employee e
JOIN Employee c ON e.chief_id = c.id
WHERE e.salary > c.salary;

-- Задание 109
-- Выведите название страны, где находится город «Salzburg»

SELECT cou.name as country_name from Countries cou
JOIN Regions r on cou.id = r.countryid
JOIN Cities c on r.id = c.regionid
WHERE c.name = 'Salzburg'

-- Задание 111
-- Посчитайте население каждого региона. В качестве результата выведите название региона и его численность населения.

SELECT r.name AS region_name,
  SUM(c.population) AS total_population
FROM Cities c
JOIN Regions r ON c.regionid = r.id
GROUP BY r.name;

-- Задание 114
-- Напишите запрос, который выведет имена пилотов, которые в качестве второго пилота (second_pilot_id) в августе 2023 года летали в New York

SELECT p.name
FROM Pilots p
	JOIN Flights f ON p.pilot_id = f.second_pilot_id
WHERE f.destination = 'New York'
	AND YEAR(f.flight_date) = 2023
	AND MONTH(f.flight_date) = 8

-- Задание 123
-- Необходимо написать SQL-запрос, который покажет всех сотрудников, у кого в работе менее трех задач. Результат предоставить в виде: имя сотрудника, количество задач в работе.

SELECT e.emp_name, COUNT(t.id) AS task_count FROM Employee e
LEFT JOIN Tasks t ON e.id = t.assignee_id
GROUP BY e.id, e.emp_name
HAVING COUNT(t.id) < 3;



