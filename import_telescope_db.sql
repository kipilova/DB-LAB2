CREATE DATABASE telescope_db;

USE telescope_db;

-- Сектор
CREATE TABLE Sectors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    coordinates VARCHAR(100),
    light_intensity DECIMAL(10, 2),
    foreign_objects TEXT,
    num_stars INT,
    num_undefined_objects INT,
    num_specified_objects INT,
    notes TEXT
);

-- Объекты
CREATE TABLE Objects (
    object_id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50),
    accuracy DECIMAL(5, 2),
    quantity INT,
    time TIME,
    date DATE,
    notes TEXT,
    sector_id INT,
    FOREIGN KEY (sector_id) REFERENCES Sectors(id)
);

-- Естественные объекты
CREATE TABLE NaturalObjects (
    object_id INT PRIMARY KEY,
    type VARCHAR(50),
    galaxy VARCHAR(50),
    accuracy DECIMAL(5, 2),
    light_flow DECIMAL(10, 2),
    associated_objects TEXT,
    notes TEXT,
    FOREIGN KEY (object_id) REFERENCES Objects(object_id)
);

-- Положение
CREATE TABLE Positions (
    position_id INT AUTO_INCREMENT PRIMARY KEY,
    earth_position VARCHAR(50),
    sun_position VARCHAR(50),
    moon_position VARCHAR(50)
);

-- Связующая таблица
CREATE TABLE TelescopeData (
    data_id INT AUTO_INCREMENT PRIMARY KEY,
    sector_id INT,
    object_id INT,
    natural_object_id INT,
    position_id INT,
    FOREIGN KEY (sector_id) REFERENCES Sectors(id),
    FOREIGN KEY (object_id) REFERENCES Objects(object_id),
    FOREIGN KEY (natural_object_id) REFERENCES NaturalObjects(object_id),
    FOREIGN KEY (position_id) REFERENCES Positions(position_id)
);

-- Добавление столбца date_update в таблицу Objects
ALTER TABLE Objects ADD COLUMN date_update DATETIME;

-- Создание триггера
DELIMITER //

CREATE TRIGGER update_objects_trigger
AFTER UPDATE ON Objects
FOR EACH ROW
BEGIN
    SET NEW.date_update = NOW();
END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE JoinTables(IN table1 VARCHAR(50), IN table2 VARCHAR(50))
BEGIN
    SET @query = CONCAT('SELECT * FROM ', table1, ' t1 JOIN ', table2, ' t2 ON t1.id = t2.id');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;
