-- Smells_Like_A_Database  |  CS317 Working Database
-- Afonso, TJ, John
-- Restart Test
DROP DATABASE IF EXISTS scent_db;
CREATE DATABASE scent_db CHARACTER SET utf8mb4;
USE scent_db;

-- Country
CREATE TABLE Country (
    Country_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(60) NOT NULL UNIQUE
);

-- Person
CREATE TABLE Person (
    Person_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(45) NOT NULL,
    Last_Name VARCHAR(45) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Country_ID INT,
    FOREIGN KEY (Country_ID) REFERENCES Country(Country_ID)
);

-- Perfumer
CREATE TABLE Perfumer (
    Person_ID INT PRIMARY KEY,
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID)
);

-- Customer
CREATE TABLE Customer (
    Person_ID INT PRIMARY KEY,
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID)
);

-- Brand
CREATE TABLE Brand (
    Brand_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(60) NOT NULL UNIQUE,
    Country_ID INT NOT NULL,
    FOREIGN KEY (Country_ID) REFERENCES Country(Country_ID)
);

-- Store
CREATE TABLE Store (
    Store_ID INT AUTO_INCREMENT PRIMARY KEY,
    City VARCHAR(45) NOT NULL,
    Street VARCHAR(100) NOT NULL,
    Building VARCHAR(45),
    Floor INT,
    Notes VARCHAR(255),
    Country_ID INT NOT NULL,
    FOREIGN KEY (Country_ID) REFERENCES Country(Country_ID)
);

-- Fragrance_Note
CREATE TABLE Fragrance_Note (
    Note_ID INT AUTO_INCREMENT PRIMARY KEY,
    Note_Name VARCHAR(45) NOT NULL UNIQUE,
    Notes VARCHAR(255)
);

-- Fragrance_Ingredient 
CREATE TABLE Fragrance_Ingredient (
    Ingredient_ID INT AUTO_INCREMENT PRIMARY KEY,
    Ingredient_Name VARCHAR(60) NOT NULL UNIQUE,
    Is_Natural BOOLEAN NOT NULL,
    Notes VARCHAR(255)
);

-- Fragrance
CREATE TABLE Fragrance (
    Fragrance_ID INT AUTO_INCREMENT PRIMARY KEY,
    Fragrance_Name VARCHAR(100) NOT NULL,
    Strength VARCHAR(45) NOT NULL,
    Size INT NOT NULL,
    Notes VARCHAR(255),
    Price DECIMAL(10,2) NOT NULL,
    Perfumer_ID INT,
    Brand_ID INT NOT NULL,
    UNIQUE (Brand_ID, Fragrance_Name, Strength, Size),
    CHECK (Size > 0),
    CHECK (Price >= 0),
    FOREIGN KEY (Perfumer_ID) REFERENCES Perfumer(Person_ID),
    FOREIGN KEY (Brand_ID) REFERENCES Brand(Brand_ID)
);

-- Fragrance_Has_Ingredient
CREATE TABLE Fragrance_Has_Ingredient (
    Fragrance_ID INT,
    Ingredient_ID INT,
    Notes VARCHAR(255),
    PRIMARY KEY (Fragrance_ID, Ingredient_ID),
    FOREIGN KEY (Fragrance_ID) REFERENCES Fragrance(Fragrance_ID),
    FOREIGN KEY (Ingredient_ID) REFERENCES Fragrance_Ingredient(Ingredient_ID)
);

-- Fragrance_Has_Note
CREATE TABLE Fragrance_Has_Note (
    Fragrance_ID INT,
    Note_ID INT,
    Notes VARCHAR(255),
    PRIMARY KEY (Fragrance_ID, Note_ID),
    FOREIGN KEY (Fragrance_ID) REFERENCES Fragrance(Fragrance_ID),
    FOREIGN KEY (Note_ID) REFERENCES Fragrance_Note(Note_ID)
);

-- Store_Inventory
CREATE TABLE Store_Inventory (
    Store_ID INT,
    Fragrance_ID INT,
    Num_Bottles INT NOT NULL,
    PRIMARY KEY (Store_ID, Fragrance_ID),
    CHECK (Num_Bottles >= 0),
    FOREIGN KEY (Store_ID) REFERENCES Store(Store_ID),
    FOREIGN KEY (Fragrance_ID) REFERENCES Fragrance(Fragrance_ID)
);

-- Purchase_Record
CREATE TABLE Purchase_Record (
    Purchase_ID INT AUTO_INCREMENT PRIMARY KEY,
    Purchase_Date DATETIME NOT NULL,
    Customer_ID INT NOT NULL,
    Fragrance_ID INT NOT NULL,
    Store_ID INT NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Person_ID),
    FOREIGN KEY (Fragrance_ID) REFERENCES Fragrance(Fragrance_ID),
    FOREIGN KEY (Store_ID) REFERENCES Store(Store_ID)
);