-- Создание базы данных (если не существует)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'GraphDB')
BEGIN
    CREATE DATABASE GraphDB;
END
GO

USE GraphDB;
GO

-- Удаление таблиц, если они существуют (в правильном порядке из-за зависимостей)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'STUDIES' AND is_node = 0)
    DROP TABLE STUDIES;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LIVES_IN' AND is_node = 0)
    DROP TABLE LIVES_IN;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'FRIEND_OF' AND is_node = 0)
    DROP TABLE FRIEND_OF;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Cities' AND is_node = 1)
    DROP TABLE Cities;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Subjects' AND is_node = 1)
    DROP TABLE Subjects;

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Students' AND is_node = 1)
    DROP TABLE Students;
GO

-- Создание узловых таблиц (nodes)
CREATE TABLE Students (
    ID INT PRIMARY KEY,
    Name NVARCHAR(100)
) AS NODE;

CREATE TABLE Subjects (
    ID INT PRIMARY KEY,
    Title NVARCHAR(100)
) AS NODE;

CREATE TABLE Cities (
    ID INT PRIMARY KEY,
    CityName NVARCHAR(100)
) AS NODE;

-- Создание рёберных таблиц (edges)
CREATE TABLE FRIEND_OF AS EDGE;
CREATE TABLE LIVES_IN AS EDGE;
CREATE TABLE STUDIES AS EDGE;
GO

-- Заполнение таблиц узлов
INSERT INTO Students (ID, Name) VALUES
(1, 'Аня'), (2, 'Борис'), (3, 'Вика'), (4, 'Глеб'), (5, 'Дина'),
(6, 'Егор'), (7, 'Женя'), (8, 'Зоя'), (9, 'Илья'), (10, 'Катя');

INSERT INTO Subjects (ID, Title) VALUES
(1, 'Математика'), (2, 'Физика'), (3, 'История'), (4, 'Информатика'), (5, 'Литература'),
(6, 'Биология'), (7, 'Химия'), (8, 'Английский'), (9, 'География'), (10, 'Философия');

INSERT INTO Cities (ID, CityName) VALUES
(1, 'Москва'), (2, 'Санкт-Петербург'), (3, 'Казань'), (4, 'Екатеринбург'), (5, 'Новосибирск'),
(6, 'Воронеж'), (7, 'Нижний Новгород'), (8, 'Краснодар'), (9, 'Томск'), (10, 'Ростов-на-Дону');
GO


-- Усложнённые связи дружбы
DELETE FROM FRIEND_OF;

INSERT INTO FRIEND_OF ($from_id, $to_id) VALUES
((SELECT $node_id FROM Students WHERE ID = 1), (SELECT $node_id FROM Students WHERE ID = 2)),
((SELECT $node_id FROM Students WHERE ID = 1), (SELECT $node_id FROM Students WHERE ID = 3)),
((SELECT $node_id FROM Students WHERE ID = 2), (SELECT $node_id FROM Students WHERE ID = 4)),
((SELECT $node_id FROM Students WHERE ID = 2), (SELECT $node_id FROM Students WHERE ID = 5)),
((SELECT $node_id FROM Students WHERE ID = 3), (SELECT $node_id FROM Students WHERE ID = 6)),
((SELECT $node_id FROM Students WHERE ID = 3), (SELECT $node_id FROM Students WHERE ID = 1)),
((SELECT $node_id FROM Students WHERE ID = 4), (SELECT $node_id FROM Students WHERE ID = 5)),
((SELECT $node_id FROM Students WHERE ID = 4), (SELECT $node_id FROM Students WHERE ID = 7)),
((SELECT $node_id FROM Students WHERE ID = 4), (SELECT $node_id FROM Students WHERE ID = 8)),
((SELECT $node_id FROM Students WHERE ID = 5), (SELECT $node_id FROM Students WHERE ID = 9)),
((SELECT $node_id FROM Students WHERE ID = 6), (SELECT $node_id FROM Students WHERE ID = 10)),
((SELECT $node_id FROM Students WHERE ID = 6), (SELECT $node_id FROM Students WHERE ID = 3)),
((SELECT $node_id FROM Students WHERE ID = 10), (SELECT $node_id FROM Students WHERE ID = 1));


-- Усложнённые связи проживания
DELETE FROM LIVES_IN;

INSERT INTO LIVES_IN ($from_id, $to_id) VALUES
((SELECT $node_id FROM Students WHERE ID = 1), (SELECT $node_id FROM Cities WHERE ID = 1)),
((SELECT $node_id FROM Students WHERE ID = 3), (SELECT $node_id FROM Cities WHERE ID = 1)),
((SELECT $node_id FROM Students WHERE ID = 10), (SELECT $node_id FROM Cities WHERE ID = 1)),
((SELECT $node_id FROM Students WHERE ID = 2), (SELECT $node_id FROM Cities WHERE ID = 2)),
((SELECT $node_id FROM Students WHERE ID = 6), (SELECT $node_id FROM Cities WHERE ID = 2)),
((SELECT $node_id FROM Students WHERE ID = 4), (SELECT $node_id FROM Cities WHERE ID = 3)),
((SELECT $node_id FROM Students WHERE ID = 5), (SELECT $node_id FROM Cities WHERE ID = 3)),
((SELECT $node_id FROM Students WHERE ID = 7), (SELECT $node_id FROM Cities WHERE ID = 5)),
((SELECT $node_id FROM Students WHERE ID = 8), (SELECT $node_id FROM Cities WHERE ID = 5)),
((SELECT $node_id FROM Students WHERE ID = 9), (SELECT $node_id FROM Cities WHERE ID = 9));


-- Усложнённые связи обучения
DELETE FROM STUDIES;

INSERT INTO STUDIES ($from_id, $to_id) VALUES
((SELECT $node_id FROM Students WHERE ID = 1), (SELECT $node_id FROM Subjects WHERE ID = 1)),
((SELECT $node_id FROM Students WHERE ID = 1), (SELECT $node_id FROM Subjects WHERE ID = 5)),
((SELECT $node_id FROM Students WHERE ID = 2), (SELECT $node_id FROM Subjects WHERE ID = 2)),
((SELECT $node_id FROM Students WHERE ID = 2), (SELECT $node_id FROM Subjects WHERE ID = 10)),
((SELECT $node_id FROM Students WHERE ID = 3), (SELECT $node_id FROM Subjects WHERE ID = 3)),
((SELECT $node_id FROM Students WHERE ID = 3), (SELECT $node_id FROM Subjects WHERE ID = 6)),
((SELECT $node_id FROM Students WHERE ID = 4), (SELECT $node_id FROM Subjects WHERE ID = 4)),
((SELECT $node_id FROM Students WHERE ID = 5), (SELECT $node_id FROM Subjects WHERE ID = 5)),
((SELECT $node_id FROM Students WHERE ID = 5), (SELECT $node_id FROM Subjects WHERE ID = 7)),
((SELECT $node_id FROM Students WHERE ID = 6), (SELECT $node_id FROM Subjects WHERE ID = 1)),
((SELECT $node_id FROM Students WHERE ID = 6), (SELECT $node_id FROM Subjects WHERE ID = 4)),
((SELECT $node_id FROM Students WHERE ID = 10), (SELECT $node_id FROM Subjects WHERE ID = 9)),
((SELECT $node_id FROM Students WHERE ID = 10), (SELECT $node_id FROM Subjects WHERE ID = 10));

GO

-- Удаление представлений, если они существуют
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vStudies')
    DROP VIEW vStudies;

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vLivesIn')
    DROP VIEW vLivesIn;

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vFriendship')
    DROP VIEW vFriendship;

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vCities')
    DROP VIEW vCities;

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vSubjects')
    DROP VIEW vSubjects;

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vStudents')
    DROP VIEW vStudents;
GO

-- Создание представлений для Power BI
CREATE VIEW vStudents AS
SELECT ID, Name FROM Students;
GO

CREATE VIEW vSubjects AS
SELECT ID, Title FROM Subjects;
GO

CREATE VIEW vCities AS
SELECT ID, CityName FROM Cities;
GO

CREATE VIEW vFriendship AS
SELECT 
    s1.ID AS FromStudentID,
    s2.ID AS ToStudentID
FROM Students s1, FRIEND_OF fo, Students s2
WHERE MATCH(s1-(fo)->s2);
GO

CREATE VIEW vLivesIn AS
SELECT 
    s.ID AS StudentID,
    c.ID AS CityID
FROM Students s, LIVES_IN li, Cities c
WHERE MATCH(s-(li)->c);
GO

CREATE VIEW vStudies AS
SELECT 
    s.ID AS StudentID,
    sub.ID AS SubjectID
FROM Students s, STUDIES st, Subjects sub
WHERE MATCH(s-(st)->sub);
GO

-- 1. Сначала добавляем столбцы с изображениями в таблицы
ALTER TABLE Students ADD Image NVARCHAR(100);
ALTER TABLE Cities ADD Image NVARCHAR(100);
ALTER TABLE Subjects ADD Image NVARCHAR(100);
GO

-- 2. Затем заполняем их значениями
UPDATE Students SET Image = 'Friends' + CAST(ID AS NVARCHAR(10)) WHERE ID BETWEEN 1 AND 10;
UPDATE Cities SET Image = 'City' + CAST(ID AS NVARCHAR(10)) WHERE ID BETWEEN 1 AND 10;
UPDATE Subjects SET Image = 'Subject' + CAST(ID AS NVARCHAR(10)) WHERE ID BETWEEN 1 AND 10;
GO

-- 3. Только после этого пересоздаём представления
DROP VIEW IF EXISTS vStudents;
DROP VIEW IF EXISTS vSubjects;
DROP VIEW IF EXISTS vCities;
GO

CREATE VIEW vStudents AS
SELECT ID, Name, Image FROM Students;
GO

CREATE VIEW vSubjects AS
SELECT ID, Title, Image FROM Subjects;
GO

CREATE VIEW vCities AS
SELECT ID, CityName, Image FROM Cities;
GO

-- Примеры запросов для SQL Server Graph
-- 1. Найти всех друзей Ани
SELECT @@SERVERNAME
SELECT s2.Name AS FriendName
FROM Students s1, FRIEND_OF, Students s2
WHERE MATCH(s1-(FRIEND_OF)->s2)
AND s1.Name = 'Аня';
GO

-- 2. Найти студентов, живущих в Москве
SELECT s.Name AS StudentName, c.CityName
FROM Students s, LIVES_IN, Cities c
WHERE MATCH(s-(LIVES_IN)->c)
AND c.CityName = 'Москва';
GO

-- 3. Студенты, изучающие математику
SELECT s.Name AS StudentName, sub.Title AS Subject
FROM Students s, STUDIES, Subjects sub
WHERE MATCH(s-(STUDIES)->sub)
AND sub.Title = 'Математика';
GO

-- 4. Связи между студентами и предметами через дружбу
SELECT s1.Name AS Student1, s2.Name AS Student2, sub.Title AS Subject
FROM Students s1, FRIEND_OF, Students s2, STUDIES, Subjects sub
WHERE MATCH(s1-(FRIEND_OF)->s2-(STUDIES)->sub);
GO

-- 5. Кто живёт в том же городе, что и Аня
SELECT s.Name AS StudentName, c.CityName
FROM Students a, LIVES_IN li1, Cities c, LIVES_IN li2, Students s
WHERE MATCH(a-(li1)->c<-(li2)-s)
AND a.Name = 'Аня' AND a.ID <> s.ID;
GO

-- Рекурсивные запросы для поиска путей
-- 1. Кратчайший путь дружбы от Ани до Кати
WITH FriendPath AS (
    SELECT 
        s.$node_id AS node_id,
        s.Name AS Name,
        0 AS level,
        CAST(s.Name AS NVARCHAR(MAX)) AS path
    FROM Students s
    WHERE s.Name = 'Аня'
    
    UNION ALL
    
    SELECT 
        s2.$node_id,
        s2.Name,
        fp.level + 1,
        CAST(fp.path + ' -> ' + s2.Name AS NVARCHAR(MAX))
    FROM FriendPath fp
    JOIN FRIEND_OF fo ON fp.node_id = fo.$from_id
    JOIN Students s2 ON fo.$to_id = s2.$node_id
    WHERE fp.level < 5
    AND s2.Name <> 'Аня'
)
SELECT TOP 1 path, level AS distance
FROM FriendPath
WHERE Name = 'Катя'
ORDER BY level;
GO

-- 2. Путь максимум из 3-х дружеских связей от Ильи
WITH FriendPath AS (
    SELECT 
        s.$node_id AS node_id,
        s.Name AS Name,
        0 AS level,
        CAST(s.Name AS NVARCHAR(MAX)) AS path
    FROM Students s
    WHERE s.Name = 'Илья'
    
    UNION ALL
    
    SELECT 
        s2.$node_id,
        s2.Name,
        fp.level + 1,
        CAST(fp.path + ' -> ' + s2.Name AS NVARCHAR(MAX))
    FROM FriendPath fp
    JOIN FRIEND_OF fo ON fp.node_id = fo.$from_id
    JOIN Students s2 ON fo.$to_id = s2.$node_id
    WHERE fp.level < 3
    AND s2.Name <> 'Илья'
)
SELECT path, level AS distance
FROM FriendPath
ORDER BY level, path;
GO

