-- CS317 Project Milestone Working Database
-- Afonso Azevedo, TJ Drape, John Markham
-- Sample data seed assistance provided by AI. Structure shcemas and testing group generated

-- Schemas --

DROP DATABASE IF EXISTS scent_db;
CREATE DATABASE scent_db;
USE scent_db;
SET NAMES utf8mb4;

CREATE TABLE Country (
Country_ID integer AUTO_INCREMENT Primary Key,
Name Varchar(47) Not Null Unique
);

CREATE TABLE Person (
Person_ID INTEGER AUTO_INCREMENT PRIMARY KEY,
First_Name Varchar(45),
Last_Name VARCHAR(45),
Email Varchar(45) UNIQUE,
Country_ID Integer,
Foreign Key (Country_ID) REFERENCES Country(Country_ID)
);

CREATE TABLE Fragrance_Note (
Note_ID INTEGER AUTO_INCREMENT PRIMARY KEY,
Note_Name VARCHAR(45) NOT NULL UNIQUE,
Notes VARCHAR(255)
);

CREATE TABLE Fragrance_Ingredient (
Ingredient_ID INTEGER AUTO_INCREMENT PRIMARY KEY,
Ingredient_Name VARCHAR(45),
Is_Natural Boolean,
Notes Varchar(255)
);

CREATE TABLE Store (
Store_ID INTEGER AUTO_INCREMENT PRIMARY KEY,
City Varchar(45),
Street VARCHAR(45),
Building VARCHAR(45),
Floor INTEGER,
Notes Varchar(255),
Country_ID INTEGER,

Foreign Key (Country_ID) REFERENCES Country(Country_ID)
);

CREATE TABLE Brand (
Brand_ID INTEGER AUTO_INCREMENT PRIMARY KEY,
Name Varchar(45) Not NULL Unique,
Country_ID Integer,

Foreign key (Country_ID) REFERENCES Country(Country_ID)
);

CREATE TABLE Perfumer (
Person_ID Integer PRIMARY KEY,
Foreign Key (Person_ID) REFERENCES Person(Person_ID)
);

CREATE TABLE Customer (
Person_ID Integer Primary Key,
Foreign Key (Person_ID) REFERENCES Person(Person_ID)
);

CREATE TABLE Fragrance (
Fragrance_ID INTEGER AUTO_INCREMENT PRIMARY KEY,
Fragrance_Name Varchar(45),
Strength Varchar(45),
Size Integer,
Notes Varchar(255),
Price Decimal(10,2),
Perfumer_ID INTEGER,
Brand_ID Integer,

Foreign Key (Perfumer_ID) REFERENCES Perfumer(Person_ID),
Foreign Key (Brand_ID) REFERENCES Brand(Brand_ID)
);

CREATE TABLE Fragrance_Has_Ingredient (
Fragrance_ID Integer,
Ingredient_ID Integer,
Notes VARCHAR(255),
Primary Key (Fragrance_ID, Ingredient_ID),
Foreign Key (Fragrance_ID) REFERENCES Fragrance(Fragrance_ID),
Foreign Key (Ingredient_ID) REFERENCES Fragrance_Ingredient(Ingredient_ID)
);

CREATE TABLE Fragrance_Has_Note (
Fragrance_ID Integer,
Note_ID Integer,
Notes VARCHAR(255),
Primary Key (Fragrance_ID, Note_ID),
Foreign Key (Fragrance_ID) REFERENCES Fragrance(Fragrance_ID),
Foreign Key (Note_ID) REFERENCES Fragrance_Note(Note_ID)
);

CREATE TABLE Store_Inventory (
Store_ID Integer,
Fragrance_ID Integer,
Num_Bottles Integer Not Null,
Primary Key (Store_ID, Fragrance_ID),
Foreign Key (Store_ID) REFERENCES Store(Store_ID),
Foreign Key (Fragrance_ID) REFERENCES Fragrance(Fragrance_ID)
);

CREATE TABLE Purchase_Record (
Purchase_ID Integer AUTO_INCREMENT Primary Key,
Purchase_Date DATETIME,
Customer_ID Integer Not Null,
Fragrance_ID Integer Not Null,
Store_ID Integer Not Null,
Foreign Key (Customer_ID) REFERENCES Customer(Person_ID),
Foreign Key (Fragrance_ID) REFERENCES Fragrance(Fragrance_ID),
Foreign Key (Store_ID) REFERENCES Store(Store_ID)
);


-- Sample Data --

INSERT INTO Country (Country_ID, Name) VALUES
(1, 'France'),
(2, 'United Kingdom'),
(3, 'United States');
 
INSERT INTO Brand (Brand_ID, Name, Country_ID) VALUES
(1, 'Dior', 1),
(2, 'Chanel', 1),
(3, 'Maison Francis Kurkdjian', 1),
(4, 'Creed', 2),
(5, 'Tom Ford', 3);
 
INSERT INTO Person (Person_ID, First_Name, Last_Name, Email, Country_ID) VALUES
(1, 'François', 'Demachy', NULL, NULL),
(2, 'Jacques', 'Polge', NULL, NULL),
(3, 'Francis', 'Kurkdjian', NULL, NULL),
(4, 'Jean-Christophe', 'Hérault', NULL, NULL),
(5, 'Olivier', 'Gillotin', NULL, NULL);
 
INSERT INTO Perfumer (Person_ID) VALUES (1), (2), (3), (4), (5);
 
INSERT INTO Fragrance_Note (Note_ID, Note_Name) VALUES
(1, 'Bergamot'),
(2, 'Pepper'),
(3, 'Ambroxan'),
(4, 'Grapefruit'),
(5, 'Pink Pepper'),
(6, 'Cedar'),
(7, 'Jasmine'),
(8, 'Patchouli'),
(9, 'Vanilla'),
(10, 'Tonka Bean'),
(11, 'Saffron'),
(12, 'Amberwood'),
(13, 'Pineapple'),
(14, 'Black Currant'),
(15, 'Tobacco Leaf'),
(16, 'Cacao'),
(17, 'Mandarin Orange');
 
INSERT INTO Fragrance (Fragrance_ID, Fragrance_Name, Strength, Size, Notes, Price, Perfumer_ID, Brand_ID) VALUES
(1, 'Sauvage Eau de Toilette', 'Eau de Toilette', 100, 'Price in USD; captured 2026-09-21', 145.00, 1, 1),
(2, 'Bleu de Chanel', 'Eau de Parfum', 100, 'Price in USD; captured 2026-09-21', 175.00, 2, 2),
(3, 'Coco Mademoiselle', 'Eau de Parfum', 100, 'Price in USD; captured 2026-09-21', 185.00, 2, 2),
(4, 'Baccarat Rouge 540', 'Eau de Parfum', 70, 'Price in USD; captured 2026-09-21', 275.00, 3, 3),
(5, 'Aventus', 'Eau de Parfum', 100, 'Price in USD; captured 2026-09-21', 510.00, 4, 4),
(6, 'Tobacco Vanille', 'Eau de Parfum', 50, 'Price in USD; captured 2026-09-21', 300.00, 5, 5);
 
INSERT INTO Fragrance_Ingredient (Ingredient_ID, Ingredient_Name, Is_Natural, Notes) VALUES
(1, 'Bergamot Oil', TRUE, NULL),
(2, 'Ambroxan', FALSE, 'Synthetic ambergris substitute'),
(3, 'Jasmine Absolute', TRUE, NULL),
(4, 'Hedione', FALSE, 'Synthetic jasmine-like molecule'),
(5, 'Patchouli Oil', TRUE, NULL),
(6, 'Vanilla Absolute', TRUE, NULL),
(7, 'Cedarwood Oil', TRUE, NULL),
(8, 'Iso E Super', FALSE, 'Synthetic woody-amber molecule');

INSERT INTO Fragrance_Has_Ingredient (Fragrance_ID, Ingredient_ID, Notes) VALUES
(1, 1, 'Representative; formulas are proprietary'), (1, 2, NULL),
(2, 1, NULL), (2, 8, NULL), (2, 7, NULL),
(3, 3, NULL), (3, 5, NULL), (3, 6, NULL),
(4, 4, NULL), (4, 2, NULL), (4, 7, NULL),
(5, 1, NULL), (5, 2, NULL),
(6, 6, NULL);
 
INSERT INTO Fragrance_Has_Note (Fragrance_ID, Note_ID) VALUES
(1, 1), (1, 2), (1, 3),
(2, 4), (2, 5), (2, 1), (2, 7), (2, 6),
(3, 17), (3, 1), (3, 7), (3, 8), (3, 9),
(4, 11), (4, 7), (4, 12), (4, 6),
(5, 1), (5, 14), (5, 13), (5, 5), (5, 3), (5, 6),
(6, 15), (6, 9), (6, 16), (6, 10);
 
INSERT INTO Person (Person_ID, First_Name, Last_Name, Email, Country_ID) VALUES
(6, 'Maya', 'Chen', 'maya.chen@example.com', 3),
(7, 'Liam', 'Walsh', 'liam.walsh@example.com', 2),
(8, 'Sofia', 'Martin', 'sofia.martin@example.com', 1),
(9, 'Omar', 'Haddad', 'omar.haddad@example.com', 3);
 
INSERT INTO Customer (Person_ID) VALUES (6), (7), (8), (9);
 
INSERT INTO Store (Store_ID, City, Street, Building, Floor, Notes, Country_ID) VALUES
(1, 'New York', 'Fifth Avenue', '610', 1, NULL, 3),
(2, 'Los Angeles', 'Rodeo Drive', '240', 1, NULL, 3),
(3, 'London', 'Regent Street', '88', 2, NULL, 2),
(4, 'Paris', 'Rue Saint-Honoré', '31', 1, NULL, 1);
 
INSERT INTO Store_Inventory (Store_ID, Fragrance_ID, Num_Bottles) VALUES
(1, 1, 12), (1, 2, 8), (1, 5, 3), (1, 6, 5),
(2, 1, 10), (2, 3, 6), (2, 4, 4),
(3, 2, 7), (3, 4, 2), (3, 5, 5),
(4, 3, 9), (4, 4, 6), (4, 6, 0);
 
INSERT INTO Purchase_Record (Purchase_ID, Purchase_Date, Customer_ID, Fragrance_ID, Store_ID) VALUES
(1, '2026-08-02 14:15:00', 6, 1, 1),
(2, '2026-08-15 11:40:00', 6, 6, 1),
(3, '2026-09-03 17:05:00', 6, 2, 1),
(4, '2026-08-20 13:22:00', 7, 5, 3),
(5, '2026-09-10 16:48:00', 7, 2, 3),
(6, '2026-09-05 12:10:00', 8, 3, 4),
(7, '2026-09-12 18:30:00', 9, 4, 2);

-- Verification to show database working correctly --

SHOW TABLES;
 
DESCRIBE Fragrance;
DESCRIBE Purchase_Record;
 
SELECT * FROM Country;
SELECT * FROM Brand;
SELECT * FROM Person;
SELECT * FROM Perfumer;
SELECT * FROM Customer;
SELECT * FROM Store;
SELECT * FROM Fragrance;
SELECT * FROM Fragrance_Note;
SELECT * FROM Fragrance_Has_Note;
SELECT * FROM Fragrance_Ingredient;
SELECT * FROM Fragrance_Has_Ingredient;
SELECT * FROM Store_Inventory;
SELECT * FROM Purchase_Record;

-- M:N One fragrance has many notes
SELECT Note_ID
FROM Fragrance_Has_Note
WHERE Fragrance_ID = 5;

-- M:N ONe note exists in many fragrances
SELECT Fragrance_ID
FROM Fragrance_Has_Note
WHERE Note_ID = 1;

-- 1:N One brand has many fragrances
SELECT Fragrance_Name
FROM Fragrance
WHERE Brand_ID = 2;

-- Test a primary key to show a duplicate cant be made. France is already '1'. 
-- INSERT INTO Country (Country_ID, Name) VALUES (1, 'Italy');

-- Test a unique value to show a duplicate cant be made. 
-- INSERT INTO Person (First_Name, Last_Name, Email) VALUES ('John', 'TJAFONSO', 'maya.chen@example.com');

-- Test foreign key for person who doesnt exist as a perfumer with perfumer_ID but only as a customer
-- INSERT INTO Fragrance (Fragrance_Name, Perfumer_ID, Brand_ID) VALUES ('TheNewScent', 6, 1);