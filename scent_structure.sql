USE scent_db;

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

CREATE TABLE Fragrance (
Fragrance_ID INTEGER AUTO_INCREMENT PRIMARY KEY,
Fragrance_Name Varchar(45),
Strength Varchar(45),
Size Integer,
Notes Varchar(255),
Price Decimal(10,2),
Perfumer_ID INTEGER,
Brand_ID Integer,

Foreign Key (Perfumer_ID) REFERENCES Person(Person_ID),
Foreign Key (Brand_ID) REFERENCES Brand(Brand_ID)
);
