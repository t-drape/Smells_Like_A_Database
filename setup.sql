CREATE DATABASE  IF NOT EXISTS `scent_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `scent_db`;
-- MySQL dump 10.13  Distrib 8.0.46, for macos15 (arm64)
--
-- Host: localhost    Database: scent_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Brand`
--

DROP TABLE IF EXISTS `Brand`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Brand` (
  `Brand_ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(60) NOT NULL,
  `Country_ID` int NOT NULL,
  PRIMARY KEY (`Brand_ID`),
  UNIQUE KEY `Name` (`Name`),
  KEY `Country_ID` (`Country_ID`),
  CONSTRAINT `brand_ibfk_1` FOREIGN KEY (`Country_ID`) REFERENCES `Country` (`Country_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Brand`
--

LOCK TABLES `Brand` WRITE;
/*!40000 ALTER TABLE `Brand` DISABLE KEYS */;
INSERT INTO `Brand` VALUES (1,'Dior',1),(2,'Chanel',1),(3,'Tom Ford',3),(4,'Maison Francis Kurkdjian',1),(5,'Creed',2);
/*!40000 ALTER TABLE `Brand` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Country`
--

DROP TABLE IF EXISTS `Country`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Country` (
  `Country_ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(60) NOT NULL,
  PRIMARY KEY (`Country_ID`),
  UNIQUE KEY `Name` (`Name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Country`
--

LOCK TABLES `Country` WRITE;
/*!40000 ALTER TABLE `Country` DISABLE KEYS */;
INSERT INTO `Country` VALUES (1,'France'),(4,'Portugal'),(5,'Spain'),(2,'United Kingdom'),(3,'United States');
/*!40000 ALTER TABLE `Country` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Customer`
--

DROP TABLE IF EXISTS `Customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Customer` (
  `Person_ID` int NOT NULL,
  PRIMARY KEY (`Person_ID`),
  CONSTRAINT `customer_ibfk_1` FOREIGN KEY (`Person_ID`) REFERENCES `Person` (`Person_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Customer`
--

LOCK TABLES `Customer` WRITE;
/*!40000 ALTER TABLE `Customer` DISABLE KEYS */;
INSERT INTO `Customer` VALUES (23),(24),(25),(26),(27),(28),(29),(30),(31),(32),(33),(34),(35),(36),(37);
/*!40000 ALTER TABLE `Customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Fragrance`
--

DROP TABLE IF EXISTS `Fragrance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Fragrance` (
  `Fragrance_ID` int NOT NULL AUTO_INCREMENT,
  `Fragrance_Name` varchar(100) NOT NULL,
  `Strength` varchar(45) NOT NULL,
  `Size` int NOT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  `Price` decimal(10,2) NOT NULL,
  `Perfumer_ID` int DEFAULT NULL,
  `Brand_ID` int NOT NULL,
  PRIMARY KEY (`Fragrance_ID`),
  UNIQUE KEY `Brand_ID` (`Brand_ID`,`Fragrance_Name`,`Strength`,`Size`),
  KEY `Perfumer_ID` (`Perfumer_ID`),
  CONSTRAINT `fragrance_ibfk_1` FOREIGN KEY (`Perfumer_ID`) REFERENCES `Perfumer` (`Person_ID`),
  CONSTRAINT `fragrance_ibfk_2` FOREIGN KEY (`Brand_ID`) REFERENCES `Brand` (`Brand_ID`),
  CONSTRAINT `fragrance_chk_1` CHECK ((`Size` > 0)),
  CONSTRAINT `fragrance_chk_2` CHECK ((`Price` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=209 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Fragrance`
--

LOCK TABLES `Fragrance` WRITE;
/*!40000 ALTER TABLE `Fragrance` DISABLE KEYS */;
INSERT INTO `Fragrance` VALUES (1,'Sauvage Eau de Toilette','Eau de Toilette',50,'Price in USD; captured 2026-09-21',105.00,8,1),(2,'Sauvage Eau de Toilette','Eau de Toilette',100,'Price in USD; captured 2026-09-21',145.00,8,1),(3,'Sauvage Eau de Toilette','Eau de Toilette',200,'Price in USD; captured 2026-09-21',220.00,8,1),(4,'Sauvage Eau de Parfum','Eau de Parfum',30,'Price in USD; captured 2026-09-21',95.00,8,1),(5,'Sauvage Eau de Parfum','Eau de Parfum',60,'Price in USD; captured 2026-09-21',130.00,8,1),(6,'Sauvage Eau de Parfum','Eau de Parfum',100,'Price in USD; captured 2026-09-21',175.00,8,1),(7,'Sauvage Eau de Parfum','Eau de Parfum',200,'Price in USD; captured 2026-09-21',260.00,8,1),(8,'Sauvage Parfum','Parfum',50,'Price in USD; captured 2026-09-21',150.00,8,1),(9,'Sauvage Parfum','Parfum',100,'Price in USD; captured 2026-09-21',205.00,8,1),(10,'Sauvage Elixir','Elixir',60,'Price in USD; captured 2026-09-21',199.00,8,1),(11,'Sauvage Elixir','Elixir',100,'Price in USD; captured 2026-09-21',260.00,8,1),(12,'Sauvage Eau Forte','Parfum Water',50,'Price in USD; captured 2026-09-21',130.00,7,1),(13,'Sauvage Eau Forte','Parfum Water',100,'Price in USD; captured 2026-09-21',180.00,7,1),(14,'Miss Dior Parfum','Parfum',50,'Price in USD; captured 2026-09-21',150.00,7,1),(15,'Miss Dior Parfum','Parfum',100,'Price in USD; captured 2026-09-21',205.00,7,1),(16,'Miss Dior Eau de Parfum','Eau de Parfum',30,'Price in USD; captured 2026-09-21',95.00,8,1),(17,'Miss Dior Eau de Parfum','Eau de Parfum',60,'Price in USD; captured 2026-09-21',130.00,8,1),(18,'Miss Dior Eau de Parfum','Eau de Parfum',100,'Price in USD; captured 2026-09-21',175.00,8,1),(19,'Miss Dior Eau de Parfum','Eau de Parfum',200,'Price in USD; captured 2026-09-21',260.00,8,1),(20,'Miss Dior Blooming Bouquet','Eau de Toilette',50,'Price in USD; captured 2026-09-21',105.00,8,1),(21,'Miss Dior Blooming Bouquet','Eau de Toilette',100,'Price in USD; captured 2026-09-21',145.00,8,1),(22,'Miss Dior Blooming Bouquet','Eau de Toilette',200,'Price in USD; captured 2026-09-21',220.00,8,1),(23,'J\'adore Eau de Parfum','Eau de Parfum',30,'Price in USD; captured 2026-09-21',95.00,2,1),(24,'J\'adore Eau de Parfum','Eau de Parfum',60,'Price in USD; captured 2026-09-21',130.00,2,1),(25,'J\'adore Eau de Parfum','Eau de Parfum',100,'Price in USD; captured 2026-09-21',175.00,2,1),(26,'J\'adore Eau de Parfum','Eau de Parfum',200,'Price in USD; captured 2026-09-21',260.00,2,1),(27,'J\'adore L\'Or','Essence de Parfum',50,'Price in USD; captured 2026-09-21',150.00,7,1),(28,'J\'adore L\'Or','Essence de Parfum',100,'Price in USD; captured 2026-09-21',205.00,7,1),(29,'Dior Homme Cologne','Eau de Cologne',50,'Price in USD; captured 2026-09-21',105.00,8,1),(30,'Dior Homme Cologne','Eau de Cologne',100,'Price in USD; captured 2026-09-21',145.00,8,1),(31,'Dior Homme Cologne','Eau de Cologne',200,'Price in USD; captured 2026-09-21',220.00,8,1),(32,'Dior Homme Intense','Eau de Parfum',30,'Price in USD; captured 2026-09-21',95.00,8,1),(33,'Dior Homme Intense','Eau de Parfum',60,'Price in USD; captured 2026-09-21',130.00,8,1),(34,'Dior Homme Intense','Eau de Parfum',100,'Price in USD; captured 2026-09-21',175.00,8,1),(35,'Dior Homme Intense','Eau de Parfum',200,'Price in USD; captured 2026-09-21',260.00,8,1),(36,'Fahrenheit','Eau de Toilette',50,'Price in USD; captured 2026-09-21',105.00,11,1),(37,'Fahrenheit','Eau de Toilette',100,'Price in USD; captured 2026-09-21',145.00,11,1),(38,'Fahrenheit','Eau de Toilette',200,'Price in USD; captured 2026-09-21',220.00,11,1),(39,'Eau Sauvage','Eau de Toilette',50,'Price in USD; captured 2026-09-21',105.00,5,1),(40,'Eau Sauvage','Eau de Toilette',100,'Price in USD; captured 2026-09-21',145.00,5,1),(41,'Eau Sauvage','Eau de Toilette',200,'Price in USD; captured 2026-09-21',220.00,5,1),(42,'Dioriviera','Eau de Parfum',40,'Price in USD; captured 2026-09-21',150.00,7,1),(43,'Dioriviera','Eau de Parfum',125,'Price in USD; captured 2026-09-21',330.00,7,1),(44,'Dioriviera','Eau de Parfum',250,'Price in USD; captured 2026-09-21',470.00,7,1),(45,'N°5 Eau de Parfum','Eau de Parfum',35,'Price in USD; captured 2026-09-21',118.00,9,2),(46,'N°5 Eau de Parfum','Eau de Parfum',50,'Price in USD; captured 2026-09-21',150.00,9,2),(47,'N°5 Eau de Parfum','Eau de Parfum',100,'Price in USD; captured 2026-09-21',190.00,9,2),(48,'N°5 Eau de Parfum','Eau de Parfum',200,'Price in USD; captured 2026-09-21',285.00,9,2),(49,'N°5 L’Eau','Eau de Toilette',35,'Price in USD; captured 2026-09-21',115.00,18,2),(50,'N°5 L’Eau','Eau de Toilette',50,'Price in USD; captured 2026-09-21',154.00,18,2),(51,'N°5 L’Eau','Eau de Toilette',100,'Price in USD; captured 2026-09-21',185.00,18,2),(52,'Coco Mademoiselle','Eau de Parfum',35,'Price in USD; captured 2026-09-21',115.00,9,2),(53,'Coco Mademoiselle','Eau de Parfum',50,'Price in USD; captured 2026-09-21',154.00,9,2),(54,'Coco Mademoiselle','Eau de Parfum',100,'Price in USD; captured 2026-09-21',185.00,9,2),(55,'Coco Noir','Eau de Parfum',35,'Price in USD; captured 2026-09-21',115.00,9,2),(56,'Coco Noir','Eau de Parfum',50,'Price in USD; captured 2026-09-21',154.00,9,2),(57,'Coco Noir','Eau de Parfum',100,'Price in USD; captured 2026-09-21',185.00,9,2),(58,'Chance','Eau de Parfum',35,'Price in USD; captured 2026-09-21',115.00,9,2),(59,'Chance','Eau de Parfum',50,'Price in USD; captured 2026-09-21',154.00,9,2),(60,'Chance','Eau de Parfum',100,'Price in USD; captured 2026-09-21',185.00,9,2),(61,'Chance Eau Tendre','Eau de Parfum',35,'Price in USD; captured 2026-09-21',115.00,18,2),(62,'Chance Eau Tendre','Eau de Parfum',50,'Price in USD; captured 2026-09-21',154.00,18,2),(63,'Chance Eau Tendre','Eau de Parfum',100,'Price in USD; captured 2026-09-21',185.00,18,2),(64,'Chance Eau Fraîche','Eau de Parfum',35,'Price in USD; captured 2026-09-21',115.00,18,2),(65,'Chance Eau Fraîche','Eau de Parfum',50,'Price in USD; captured 2026-09-21',154.00,18,2),(66,'Chance Eau Fraîche','Eau de Parfum',100,'Price in USD; captured 2026-09-21',185.00,18,2),(67,'Chance Eau Splendide','Eau de Parfum',35,'Price in USD; captured 2026-09-21',115.00,18,2),(68,'Chance Eau Splendide','Eau de Parfum',50,'Price in USD; captured 2026-09-21',154.00,18,2),(69,'Chance Eau Splendide','Eau de Parfum',100,'Price in USD; captured 2026-09-21',185.00,18,2),(70,'Chance Eau Splendide','Eau de Parfum',150,'Price in USD; captured 2026-09-21',225.00,18,2),(71,'Bleu de Chanel','Eau de Parfum',50,'Price in USD; captured 2026-09-21',135.00,9,2),(72,'Bleu de Chanel','Eau de Parfum',100,'Price in USD; captured 2026-09-21',175.00,9,2),(73,'Bleu de Chanel','Eau de Parfum',150,'Price in USD; captured 2026-09-21',215.00,9,2),(74,'Bleu de Chanel','Parfum',50,'Price in USD; captured 2026-09-21',165.00,18,2),(75,'Bleu de Chanel','Parfum',100,'Price in USD; captured 2026-09-21',210.00,18,2),(76,'Bleu de Chanel','Parfum',150,'Price in USD; captured 2026-09-21',260.00,18,2),(77,'Gabrielle Chanel','Eau de Parfum',35,'Price in USD; captured 2026-09-21',115.00,18,2),(78,'Gabrielle Chanel','Eau de Parfum',50,'Price in USD; captured 2026-09-21',154.00,18,2),(79,'Gabrielle Chanel','Eau de Parfum',100,'Price in USD; captured 2026-09-21',185.00,18,2),(80,'Comète','Eau de Parfum',75,'Price in USD; captured 2026-09-21',325.00,18,2),(81,'Comète','Eau de Parfum',200,'Price in USD; captured 2026-09-21',500.00,18,2),(82,'Coromandel','Eau de Parfum',75,'Price in USD; captured 2026-09-21',325.00,9,2),(83,'Coromandel','Eau de Parfum',200,'Price in USD; captured 2026-09-21',500.00,9,2),(84,'1957','Eau de Parfum',75,'Price in USD; captured 2026-09-21',325.00,18,2),(85,'1957','Eau de Parfum',200,'Price in USD; captured 2026-09-21',500.00,18,2),(86,'Black Orchid','Eau de Parfum',30,'Price in USD; captured 2026-09-21',115.00,4,3),(87,'Black Orchid','Eau de Parfum',50,'Price in USD; captured 2026-09-21',165.00,4,3),(88,'Black Orchid','Eau de Parfum',100,'Price in USD; captured 2026-09-21',240.00,4,3),(89,'Ombré Leather','Eau de Parfum',30,'Price in USD; captured 2026-09-21',115.00,22,3),(90,'Ombré Leather','Eau de Parfum',50,'Price in USD; captured 2026-09-21',165.00,22,3),(91,'Ombré Leather','Eau de Parfum',100,'Price in USD; captured 2026-09-21',240.00,22,3),(92,'Oud Wood','Eau de Parfum',10,'Price in USD; captured 2026-09-21',80.00,19,3),(93,'Oud Wood','Eau de Parfum',30,'Price in USD; captured 2026-09-21',195.00,19,3),(94,'Oud Wood','Eau de Parfum',50,'Price in USD; captured 2026-09-21',300.00,19,3),(95,'Oud Wood','Eau de Parfum',100,'Price in USD; captured 2026-09-21',445.00,19,3),(96,'Oud Wood','Eau de Parfum',250,'Price in USD; captured 2026-09-21',895.00,19,3),(97,'Tobacco Vanille','Eau de Parfum',10,'Price in USD; captured 2026-09-21',80.00,17,3),(98,'Tobacco Vanille','Eau de Parfum',30,'Price in USD; captured 2026-09-21',195.00,17,3),(99,'Tobacco Vanille','Eau de Parfum',50,'Price in USD; captured 2026-09-21',300.00,17,3),(100,'Tobacco Vanille','Eau de Parfum',100,'Price in USD; captured 2026-09-21',445.00,17,3),(101,'Tobacco Vanille','Eau de Parfum',250,'Price in USD; captured 2026-09-21',895.00,17,3),(102,'Lost Cherry','Eau de Parfum',10,'Price in USD; captured 2026-09-21',95.00,13,3),(103,'Lost Cherry','Eau de Parfum',30,'Price in USD; captured 2026-09-21',255.00,13,3),(104,'Lost Cherry','Eau de Parfum',50,'Price in USD; captured 2026-09-21',405.00,13,3),(105,'Lost Cherry','Eau de Parfum',100,'Price in USD; captured 2026-09-21',650.00,13,3),(106,'Bitter Peach','Eau de Parfum',10,'Price in USD; captured 2026-09-21',95.00,20,3),(107,'Bitter Peach','Eau de Parfum',30,'Price in USD; captured 2026-09-21',255.00,20,3),(108,'Bitter Peach','Eau de Parfum',50,'Price in USD; captured 2026-09-21',405.00,20,3),(109,'Bitter Peach','Eau de Parfum',100,'Price in USD; captured 2026-09-21',650.00,20,3),(110,'Neroli Portofino','Eau de Parfum',10,'Price in USD; captured 2026-09-21',80.00,20,3),(111,'Neroli Portofino','Eau de Parfum',30,'Price in USD; captured 2026-09-21',195.00,20,3),(112,'Neroli Portofino','Eau de Parfum',50,'Price in USD; captured 2026-09-21',300.00,20,3),(113,'Neroli Portofino','Eau de Parfum',100,'Price in USD; captured 2026-09-21',445.00,20,3),(114,'Neroli Portofino','Eau de Parfum',250,'Price in USD; captured 2026-09-21',895.00,20,3),(115,'Soleil Blanc','Eau de Parfum',10,'Price in USD; captured 2026-09-21',80.00,14,3),(116,'Soleil Blanc','Eau de Parfum',30,'Price in USD; captured 2026-09-21',195.00,14,3),(117,'Soleil Blanc','Eau de Parfum',50,'Price in USD; captured 2026-09-21',300.00,14,3),(118,'Soleil Blanc','Eau de Parfum',100,'Price in USD; captured 2026-09-21',445.00,14,3),(119,'Soleil Blanc','Eau de Parfum',250,'Price in USD; captured 2026-09-21',895.00,14,3),(120,'Vanilla Sex','Eau de Parfum',10,'Price in USD; captured 2026-09-21',95.00,21,3),(121,'Vanilla Sex','Eau de Parfum',30,'Price in USD; captured 2026-09-21',255.00,21,3),(122,'Vanilla Sex','Eau de Parfum',50,'Price in USD; captured 2026-09-21',405.00,21,3),(123,'Vanilla Sex','Eau de Parfum',100,'Price in USD; captured 2026-09-21',650.00,21,3),(124,'Ébène Fumé','Eau de Parfum',10,'Price in USD; captured 2026-09-21',80.00,20,3),(125,'Ébène Fumé','Eau de Parfum',30,'Price in USD; captured 2026-09-21',195.00,20,3),(126,'Ébène Fumé','Eau de Parfum',50,'Price in USD; captured 2026-09-21',300.00,20,3),(127,'Ébène Fumé','Eau de Parfum',100,'Price in USD; captured 2026-09-21',445.00,20,3),(128,'Ébène Fumé','Eau de Parfum',250,'Price in USD; captured 2026-09-21',895.00,20,3),(129,'Cherry Smoke','Eau de Parfum',10,'Price in USD; captured 2026-09-21',95.00,13,3),(130,'Cherry Smoke','Eau de Parfum',30,'Price in USD; captured 2026-09-21',255.00,13,3),(131,'Cherry Smoke','Eau de Parfum',50,'Price in USD; captured 2026-09-21',405.00,13,3),(132,'Cherry Smoke','Eau de Parfum',100,'Price in USD; captured 2026-09-21',650.00,13,3),(133,'Beau de Jour','Eau de Parfum',10,'Price in USD; captured 2026-09-21',80.00,1,3),(134,'Beau de Jour','Eau de Parfum',30,'Price in USD; captured 2026-09-21',195.00,1,3),(135,'Beau de Jour','Eau de Parfum',50,'Price in USD; captured 2026-09-21',300.00,1,3),(136,'Beau de Jour','Eau de Parfum',100,'Price in USD; captured 2026-09-21',445.00,1,3),(137,'Beau de Jour','Eau de Parfum',250,'Price in USD; captured 2026-09-21',895.00,1,3),(138,'Bois Pacifique','Eau de Parfum',10,'Price in USD; captured 2026-09-21',80.00,20,3),(139,'Bois Pacifique','Eau de Parfum',30,'Price in USD; captured 2026-09-21',195.00,20,3),(140,'Bois Pacifique','Eau de Parfum',50,'Price in USD; captured 2026-09-21',300.00,20,3),(141,'Bois Pacifique','Eau de Parfum',100,'Price in USD; captured 2026-09-21',445.00,20,3),(142,'Bois Pacifique','Eau de Parfum',250,'Price in USD; captured 2026-09-21',895.00,20,3),(143,'Baccarat Rouge 540','Eau de Parfum',35,'Price in USD; captured 2026-09-21',180.00,7,4),(144,'Baccarat Rouge 540','Eau de Parfum',70,'Price in USD; captured 2026-09-21',275.00,7,4),(145,'Baccarat Rouge 540','Eau de Parfum',200,'Price in USD; captured 2026-09-21',535.00,7,4),(146,'Baccarat Rouge 540','Extrait de Parfum',35,'Price in USD; captured 2026-09-21',320.00,7,4),(147,'Baccarat Rouge 540','Extrait de Parfum',70,'Price in USD; captured 2026-09-21',475.00,7,4),(148,'Baccarat Rouge 540','Extrait de Parfum',200,'Price in USD; captured 2026-09-21',985.00,7,4),(149,'Grand Soir','Eau de Parfum',35,'Price in USD; captured 2026-09-21',180.00,7,4),(150,'Grand Soir','Eau de Parfum',70,'Price in USD; captured 2026-09-21',275.00,7,4),(151,'Grand Soir','Eau de Parfum',200,'Price in USD; captured 2026-09-21',535.00,7,4),(152,'724','Eau de Parfum',35,'Price in USD; captured 2026-09-21',180.00,7,4),(153,'724','Eau de Parfum',70,'Price in USD; captured 2026-09-21',275.00,7,4),(154,'724','Eau de Parfum',200,'Price in USD; captured 2026-09-21',535.00,7,4),(155,'APOM','Eau de Parfum',35,'Price in USD; captured 2026-09-21',180.00,7,4),(156,'APOM','Eau de Parfum',70,'Price in USD; captured 2026-09-21',275.00,7,4),(157,'APOM','Eau de Parfum',200,'Price in USD; captured 2026-09-21',535.00,7,4),(158,'Gentle Fluidity Gold','Eau de Parfum',35,'Price in USD; captured 2026-09-21',180.00,7,4),(159,'Gentle Fluidity Gold','Eau de Parfum',70,'Price in USD; captured 2026-09-21',275.00,7,4),(160,'Gentle Fluidity Gold','Eau de Parfum',200,'Price in USD; captured 2026-09-21',535.00,7,4),(161,'Gentle Fluidity Silver','Eau de Parfum',35,'Price in USD; captured 2026-09-21',180.00,7,4),(162,'Gentle Fluidity Silver','Eau de Parfum',70,'Price in USD; captured 2026-09-21',275.00,7,4),(163,'Gentle Fluidity Silver','Eau de Parfum',200,'Price in USD; captured 2026-09-21',535.00,7,4),(164,'OUD','Eau de Parfum',35,'Price in USD; captured 2026-09-21',220.00,7,4),(165,'OUD','Eau de Parfum',70,'Price in USD; captured 2026-09-21',340.00,7,4),(166,'OUD','Eau de Parfum',200,'Price in USD; captured 2026-09-21',665.00,7,4),(167,'OUD Satin Mood','Eau de Parfum',35,'Price in USD; captured 2026-09-21',220.00,7,4),(168,'OUD Satin Mood','Eau de Parfum',70,'Price in USD; captured 2026-09-21',340.00,7,4),(169,'OUD Satin Mood','Eau de Parfum',200,'Price in USD; captured 2026-09-21',665.00,7,4),(170,'À la rose','Eau de Parfum',35,'Price in USD; captured 2026-09-21',180.00,7,4),(171,'À la rose','Eau de Parfum',70,'Price in USD; captured 2026-09-21',275.00,7,4),(172,'À la rose','Eau de Parfum',200,'Price in USD; captured 2026-09-21',535.00,7,4),(173,'Aqua Universalis','Eau de Toilette',35,'Price in USD; captured 2026-09-21',170.00,7,4),(174,'Aqua Universalis','Eau de Toilette',70,'Price in USD; captured 2026-09-21',265.00,7,4),(175,'Aqua Universalis','Eau de Toilette',200,'Price in USD; captured 2026-09-21',515.00,7,4),(176,'Aventus','Eau de Parfum',30,'Price in USD; captured 2026-09-21',270.00,10,5),(177,'Aventus','Eau de Parfum',50,'Price in USD; captured 2026-09-21',380.00,10,5),(178,'Aventus','Eau de Parfum',100,'Price in USD; captured 2026-09-21',510.00,10,5),(179,'Aventus','Eau de Parfum',240,'Price in USD; captured 2026-09-21',850.00,10,5),(180,'Aventus','Eau de Parfum',490,'Price in USD; captured 2026-09-21',1290.00,10,5),(181,'Aventus','Eau de Parfum',980,'Price in USD; captured 2026-09-21',2100.00,10,5),(182,'Aventus for Her','Eau de Parfum',30,'Price in USD; captured 2026-09-21',310.00,16,5),(183,'Aventus for Her','Eau de Parfum',75,'Price in USD; captured 2026-09-21',460.00,16,5),(184,'Aventus for Her','Eau de Parfum',240,'Price in USD; captured 2026-09-21',850.00,16,5),(185,'Aventus for Her','Eau de Parfum',500,'Price in USD; captured 2026-09-21',1385.00,16,5),(186,'Aventus for Her','Eau de Parfum',1000,'Price in USD; captured 2026-09-21',2240.00,16,5),(187,'Green Irish Tweed','Eau de Parfum',50,'Price in USD; captured 2026-09-21',380.00,16,5),(188,'Green Irish Tweed','Eau de Parfum',100,'Price in USD; captured 2026-09-21',510.00,16,5),(189,'Silver Mountain Water','Eau de Parfum',50,'Price in USD; captured 2026-09-21',380.00,16,5),(190,'Silver Mountain Water','Eau de Parfum',100,'Price in USD; captured 2026-09-21',510.00,16,5),(191,'Millesime Imperial','Eau de Parfum',50,'Price in USD; captured 2026-09-21',380.00,16,5),(192,'Millesime Imperial','Eau de Parfum',100,'Price in USD; captured 2026-09-21',510.00,16,5),(193,'Royal Oud','Eau de Parfum',50,'Price in USD; captured 2026-09-21',380.00,16,5),(194,'Royal Oud','Eau de Parfum',100,'Price in USD; captured 2026-09-21',510.00,16,5),(195,'Viking','Eau de Parfum',50,'Price in USD; captured 2026-09-21',380.00,16,5),(196,'Viking','Eau de Parfum',100,'Price in USD; captured 2026-09-21',510.00,16,5),(197,'Original Vetiver','Eau de Parfum',50,'Price in USD; captured 2026-09-21',380.00,16,5),(198,'Original Vetiver','Eau de Parfum',100,'Price in USD; captured 2026-09-21',510.00,16,5),(199,'Queen of Silk','Eau de Parfum',30,'Price in USD; captured 2026-09-21',310.00,12,5),(200,'Queen of Silk','Eau de Parfum',75,'Price in USD; captured 2026-09-21',460.00,12,5),(201,'Centaurus','Eau de Parfum',50,'Price in USD; captured 2026-09-21',380.00,NULL,5),(202,'Centaurus','Eau de Parfum',100,'Price in USD; captured 2026-09-21',510.00,NULL,5),(203,'Eladaria','Eau de Parfum',30,'Price in USD; captured 2026-09-21',310.00,6,5),(204,'Eladaria','Eau de Parfum',75,'Price in USD; captured 2026-09-21',460.00,6,5),(205,'Oud Zarian','Eau de Parfum',50,'Price in USD; captured 2026-09-21',545.00,3,5),(206,'Oud Zarian','Eau de Parfum',100,'Price in USD; captured 2026-09-21',650.00,3,5),(207,'Wild Vetiver','Eau de Parfum',50,'Price in USD; captured 2026-09-21',380.00,15,5),(208,'Wild Vetiver','Eau de Parfum',100,'Price in USD; captured 2026-09-21',510.00,15,5);
/*!40000 ALTER TABLE `Fragrance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Fragrance_Has_Ingredient`
--

DROP TABLE IF EXISTS `Fragrance_Has_Ingredient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Fragrance_Has_Ingredient` (
  `Fragrance_ID` int NOT NULL,
  `Ingredient_ID` int NOT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Fragrance_ID`,`Ingredient_ID`),
  KEY `Ingredient_ID` (`Ingredient_ID`),
  CONSTRAINT `fragrance_has_ingredient_ibfk_1` FOREIGN KEY (`Fragrance_ID`) REFERENCES `Fragrance` (`Fragrance_ID`),
  CONSTRAINT `fragrance_has_ingredient_ibfk_2` FOREIGN KEY (`Ingredient_ID`) REFERENCES `Fragrance_Ingredient` (`Ingredient_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Fragrance_Has_Ingredient`
--

LOCK TABLES `Fragrance_Has_Ingredient` WRITE;
/*!40000 ALTER TABLE `Fragrance_Has_Ingredient` DISABLE KEYS */;
INSERT INTO `Fragrance_Has_Ingredient` VALUES (1,1,NULL),(1,7,NULL),(2,1,NULL),(2,7,NULL),(3,1,NULL),(3,7,NULL),(4,1,NULL),(4,7,NULL),(4,15,NULL),(5,1,NULL),(5,7,NULL),(5,15,NULL),(6,1,NULL),(6,7,NULL),(6,15,NULL),(7,1,NULL),(7,7,NULL),(7,15,NULL),(23,8,NULL),(24,8,NULL),(25,8,NULL),(26,8,NULL),(39,2,NULL),(40,2,NULL),(41,2,NULL),(45,4,NULL),(45,8,NULL),(45,9,NULL),(45,10,NULL),(46,4,NULL),(46,8,NULL),(46,9,NULL),(46,10,NULL),(47,4,NULL),(47,8,NULL),(47,9,NULL),(47,10,NULL),(48,4,NULL),(48,8,NULL),(48,9,NULL),(48,10,NULL),(52,11,NULL),(53,11,NULL),(54,11,NULL),(71,3,NULL),(71,14,NULL),(72,3,NULL),(72,14,NULL),(73,3,NULL),(73,14,NULL),(74,3,NULL),(74,14,NULL),(75,3,NULL),(75,14,NULL),(76,3,NULL),(76,14,NULL),(86,11,NULL),(86,16,NULL),(87,11,NULL),(87,16,NULL),(88,11,NULL),(88,16,NULL),(97,16,NULL),(97,17,NULL),(98,16,NULL),(98,17,NULL),(99,16,NULL),(99,17,NULL),(100,16,NULL),(100,17,NULL),(101,16,NULL),(101,17,NULL),(143,1,NULL),(143,2,NULL),(143,5,NULL),(143,6,NULL),(143,14,NULL),(144,1,NULL),(144,2,NULL),(144,5,NULL),(144,6,NULL),(144,14,NULL),(145,1,NULL),(145,2,NULL),(145,5,NULL),(145,6,NULL),(145,14,NULL),(146,1,NULL),(146,2,NULL),(146,5,NULL),(146,6,NULL),(146,14,NULL),(147,1,NULL),(147,2,NULL),(147,5,NULL),(147,6,NULL),(147,14,NULL),(148,1,NULL),(148,2,NULL),(148,5,NULL),(148,6,NULL),(148,14,NULL),(170,9,NULL),(171,9,NULL),(172,9,NULL),(176,13,NULL),(177,13,NULL),(178,13,NULL),(179,13,NULL),(180,13,NULL),(181,13,NULL),(197,12,NULL),(198,12,NULL),(207,12,NULL),(208,12,NULL);
/*!40000 ALTER TABLE `Fragrance_Has_Ingredient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Fragrance_Has_Note`
--

DROP TABLE IF EXISTS `Fragrance_Has_Note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Fragrance_Has_Note` (
  `Fragrance_ID` int NOT NULL,
  `Note_ID` int NOT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Fragrance_ID`,`Note_ID`),
  KEY `Note_ID` (`Note_ID`),
  CONSTRAINT `fragrance_has_note_ibfk_1` FOREIGN KEY (`Fragrance_ID`) REFERENCES `Fragrance` (`Fragrance_ID`),
  CONSTRAINT `fragrance_has_note_ibfk_2` FOREIGN KEY (`Note_ID`) REFERENCES `Fragrance_Note` (`Note_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Fragrance_Has_Note`
--

LOCK TABLES `Fragrance_Has_Note` WRITE;
/*!40000 ALTER TABLE `Fragrance_Has_Note` DISABLE KEYS */;
INSERT INTO `Fragrance_Has_Note` VALUES (1,10,NULL),(1,19,NULL),(1,137,NULL),(2,10,NULL),(2,19,NULL),(2,137,NULL),(3,10,NULL),(3,19,NULL),(3,137,NULL),(4,10,NULL),(4,19,NULL),(4,88,NULL),(4,115,NULL),(4,130,NULL),(4,158,NULL),(4,166,NULL),(5,10,NULL),(5,19,NULL),(5,88,NULL),(5,115,NULL),(5,130,NULL),(5,158,NULL),(5,166,NULL),(6,10,NULL),(6,19,NULL),(6,88,NULL),(6,115,NULL),(6,130,NULL),(6,158,NULL),(6,166,NULL),(7,10,NULL),(7,19,NULL),(7,88,NULL),(7,115,NULL),(7,130,NULL),(7,158,NULL),(7,166,NULL),(8,19,NULL),(8,88,NULL),(8,100,NULL),(8,115,NULL),(8,133,NULL),(8,155,NULL),(8,158,NULL),(8,175,NULL),(8,181,NULL),(9,19,NULL),(9,88,NULL),(9,100,NULL),(9,115,NULL),(9,133,NULL),(9,155,NULL),(9,158,NULL),(9,175,NULL),(9,181,NULL),(10,6,NULL),(10,34,NULL),(10,42,NULL),(10,68,NULL),(10,75,NULL),(10,88,NULL),(10,93,NULL),(10,115,NULL),(10,133,NULL),(10,155,NULL),(11,6,NULL),(11,34,NULL),(11,42,NULL),(11,68,NULL),(11,75,NULL),(11,88,NULL),(11,93,NULL),(11,115,NULL),(11,133,NULL),(11,155,NULL),(12,56,NULL),(12,88,NULL),(12,109,NULL),(12,163,NULL),(13,56,NULL),(13,88,NULL),(13,109,NULL),(13,163,NULL),(14,8,NULL),(14,13,NULL),(14,15,NULL),(14,100,NULL),(14,108,NULL),(14,133,NULL),(14,134,NULL),(14,167,NULL),(14,190,NULL),(15,8,NULL),(15,13,NULL),(15,15,NULL),(15,100,NULL),(15,108,NULL),(15,133,NULL),(15,134,NULL),(15,167,NULL),(15,190,NULL),(16,13,NULL),(16,18,NULL),(16,81,NULL),(16,95,NULL),(16,109,NULL),(16,134,NULL),(16,136,NULL),(16,149,NULL),(16,155,NULL),(16,175,NULL),(16,181,NULL),(17,13,NULL),(17,18,NULL),(17,81,NULL),(17,95,NULL),(17,109,NULL),(17,134,NULL),(17,136,NULL),(17,149,NULL),(17,155,NULL),(17,175,NULL),(17,181,NULL),(18,13,NULL),(18,18,NULL),(18,81,NULL),(18,95,NULL),(18,109,NULL),(18,134,NULL),(18,136,NULL),(18,149,NULL),(18,155,NULL),(18,175,NULL),(18,181,NULL),(19,13,NULL),(19,18,NULL),(19,81,NULL),(19,95,NULL),(19,109,NULL),(19,134,NULL),(19,136,NULL),(19,149,NULL),(19,155,NULL),(19,175,NULL),(19,181,NULL),(20,19,NULL),(20,51,NULL),(20,136,NULL),(20,169,NULL),(20,188,NULL),(21,19,NULL),(21,51,NULL),(21,136,NULL),(21,169,NULL),(21,188,NULL),(22,19,NULL),(22,51,NULL),(22,136,NULL),(22,169,NULL),(22,188,NULL),(23,19,NULL),(23,27,NULL),(23,38,NULL),(23,61,NULL),(23,83,NULL),(23,95,NULL),(23,99,NULL),(23,100,NULL),(23,102,NULL),(23,109,NULL),(23,123,NULL),(23,134,NULL),(23,135,NULL),(23,144,NULL),(23,149,NULL),(23,177,NULL),(23,181,NULL),(23,184,NULL),(24,19,NULL),(24,27,NULL),(24,38,NULL),(24,61,NULL),(24,83,NULL),(24,95,NULL),(24,99,NULL),(24,100,NULL),(24,102,NULL),(24,109,NULL),(24,123,NULL),(24,134,NULL),(24,135,NULL),(24,144,NULL),(24,149,NULL),(24,177,NULL),(24,181,NULL),(24,184,NULL),(25,19,NULL),(25,27,NULL),(25,38,NULL),(25,61,NULL),(25,83,NULL),(25,95,NULL),(25,99,NULL),(25,100,NULL),(25,102,NULL),(25,109,NULL),(25,123,NULL),(25,134,NULL),(25,135,NULL),(25,144,NULL),(25,149,NULL),(25,177,NULL),(25,181,NULL),(25,184,NULL),(26,19,NULL),(26,27,NULL),(26,38,NULL),(26,61,NULL),(26,83,NULL),(26,95,NULL),(26,99,NULL),(26,100,NULL),(26,102,NULL),(26,109,NULL),(26,123,NULL),(26,134,NULL),(26,135,NULL),(26,144,NULL),(26,149,NULL),(26,177,NULL),(26,181,NULL),(26,184,NULL),(27,83,NULL),(27,122,NULL),(27,149,NULL),(28,83,NULL),(28,122,NULL),(28,149,NULL),(29,32,NULL),(29,69,NULL),(29,109,NULL),(30,32,NULL),(30,69,NULL),(30,109,NULL),(31,32,NULL),(31,69,NULL),(31,109,NULL),(32,9,NULL),(32,81,NULL),(32,88,NULL),(32,135,NULL),(32,183,NULL),(32,186,NULL),(33,9,NULL),(33,81,NULL),(33,88,NULL),(33,135,NULL),(33,183,NULL),(33,186,NULL),(34,9,NULL),(34,81,NULL),(34,88,NULL),(34,135,NULL),(34,183,NULL),(34,186,NULL),(35,9,NULL),(35,81,NULL),(35,88,NULL),(35,135,NULL),(35,183,NULL),(35,186,NULL),(36,6,NULL),(36,19,NULL),(36,35,NULL),(36,38,NULL),(36,40,NULL),(36,76,NULL),(36,79,NULL),(36,83,NULL),(36,88,NULL),(36,89,NULL),(36,90,NULL),(36,95,NULL),(36,100,NULL),(36,109,NULL),(36,115,NULL),(36,116,NULL),(36,133,NULL),(36,155,NULL),(36,175,NULL),(36,183,NULL),(36,185,NULL),(37,6,NULL),(37,19,NULL),(37,35,NULL),(37,38,NULL),(37,40,NULL),(37,76,NULL),(37,79,NULL),(37,83,NULL),(37,88,NULL),(37,89,NULL),(37,90,NULL),(37,95,NULL),(37,100,NULL),(37,109,NULL),(37,115,NULL),(37,116,NULL),(37,133,NULL),(37,155,NULL),(37,175,NULL),(37,183,NULL),(37,185,NULL),(38,6,NULL),(38,19,NULL),(38,35,NULL),(38,38,NULL),(38,40,NULL),(38,76,NULL),(38,79,NULL),(38,83,NULL),(38,88,NULL),(38,89,NULL),(38,90,NULL),(38,95,NULL),(38,100,NULL),(38,109,NULL),(38,115,NULL),(38,116,NULL),(38,133,NULL),(38,155,NULL),(38,175,NULL),(38,183,NULL),(38,185,NULL),(39,6,NULL),(39,17,NULL),(39,19,NULL),(39,35,NULL),(39,49,NULL),(39,50,NULL),(39,83,NULL),(39,88,NULL),(39,90,NULL),(39,109,NULL),(39,118,NULL),(39,126,NULL),(39,133,NULL),(39,149,NULL),(39,151,NULL),(39,155,NULL),(39,183,NULL),(40,6,NULL),(40,17,NULL),(40,19,NULL),(40,35,NULL),(40,49,NULL),(40,50,NULL),(40,83,NULL),(40,88,NULL),(40,90,NULL),(40,109,NULL),(40,118,NULL),(40,126,NULL),(40,133,NULL),(40,149,NULL),(40,151,NULL),(40,155,NULL),(40,183,NULL),(41,6,NULL),(41,17,NULL),(41,19,NULL),(41,35,NULL),(41,49,NULL),(41,50,NULL),(41,83,NULL),(41,88,NULL),(41,90,NULL),(41,109,NULL),(41,118,NULL),(41,126,NULL),(41,133,NULL),(41,149,NULL),(41,151,NULL),(41,155,NULL),(41,183,NULL),(42,57,NULL),(42,149,NULL),(43,57,NULL),(43,149,NULL),(44,57,NULL),(44,149,NULL),(45,4,NULL),(45,19,NULL),(45,81,NULL),(45,83,NULL),(45,95,NULL),(45,114,NULL),(45,118,NULL),(45,133,NULL),(45,134,NULL),(45,149,NULL),(45,155,NULL),(45,181,NULL),(45,183,NULL),(45,193,NULL),(46,4,NULL),(46,19,NULL),(46,81,NULL),(46,83,NULL),(46,95,NULL),(46,114,NULL),(46,118,NULL),(46,133,NULL),(46,134,NULL),(46,149,NULL),(46,155,NULL),(46,181,NULL),(46,183,NULL),(46,193,NULL),(47,4,NULL),(47,19,NULL),(47,81,NULL),(47,83,NULL),(47,95,NULL),(47,114,NULL),(47,118,NULL),(47,133,NULL),(47,134,NULL),(47,149,NULL),(47,155,NULL),(47,181,NULL),(47,183,NULL),(47,193,NULL),(48,4,NULL),(48,19,NULL),(48,81,NULL),(48,83,NULL),(48,95,NULL),(48,114,NULL),(48,118,NULL),(48,133,NULL),(48,134,NULL),(48,149,NULL),(48,155,NULL),(48,181,NULL),(48,183,NULL),(48,193,NULL),(49,4,NULL),(49,19,NULL),(49,38,NULL),(49,83,NULL),(49,90,NULL),(49,100,NULL),(49,101,NULL),(49,109,NULL),(49,114,NULL),(49,121,NULL),(49,126,NULL),(49,181,NULL),(49,193,NULL),(50,4,NULL),(50,19,NULL),(50,38,NULL),(50,83,NULL),(50,90,NULL),(50,100,NULL),(50,101,NULL),(50,109,NULL),(50,114,NULL),(50,121,NULL),(50,126,NULL),(50,181,NULL),(50,193,NULL),(51,4,NULL),(51,19,NULL),(51,38,NULL),(51,83,NULL),(51,90,NULL),(51,100,NULL),(51,101,NULL),(51,109,NULL),(51,114,NULL),(51,121,NULL),(51,126,NULL),(51,181,NULL),(51,193,NULL),(52,19,NULL),(52,83,NULL),(52,100,NULL),(52,104,NULL),(52,120,NULL),(52,121,NULL),(52,122,NULL),(52,133,NULL),(52,175,NULL),(52,178,NULL),(52,181,NULL),(52,183,NULL),(52,188,NULL),(53,19,NULL),(53,83,NULL),(53,100,NULL),(53,104,NULL),(53,120,NULL),(53,121,NULL),(53,122,NULL),(53,133,NULL),(53,175,NULL),(53,178,NULL),(53,181,NULL),(53,183,NULL),(53,188,NULL),(54,19,NULL),(54,83,NULL),(54,100,NULL),(54,104,NULL),(54,120,NULL),(54,121,NULL),(54,122,NULL),(54,133,NULL),(54,175,NULL),(54,178,NULL),(54,181,NULL),(54,183,NULL),(54,188,NULL),(55,18,NULL),(55,19,NULL),(55,46,NULL),(55,68,NULL),(55,83,NULL),(55,113,NULL),(55,119,NULL),(55,133,NULL),(55,149,NULL),(55,150,NULL),(55,155,NULL),(55,175,NULL),(55,181,NULL),(55,188,NULL),(56,18,NULL),(56,19,NULL),(56,46,NULL),(56,68,NULL),(56,83,NULL),(56,113,NULL),(56,119,NULL),(56,133,NULL),(56,149,NULL),(56,150,NULL),(56,155,NULL),(56,175,NULL),(56,181,NULL),(56,188,NULL),(57,18,NULL),(57,19,NULL),(57,46,NULL),(57,68,NULL),(57,83,NULL),(57,113,NULL),(57,119,NULL),(57,133,NULL),(57,149,NULL),(57,150,NULL),(57,155,NULL),(57,175,NULL),(57,181,NULL),(57,188,NULL),(58,83,NULL),(58,133,NULL),(58,141,NULL),(58,181,NULL),(58,188,NULL),(59,83,NULL),(59,133,NULL),(59,141,NULL),(59,181,NULL),(59,188,NULL),(60,83,NULL),(60,133,NULL),(60,141,NULL),(60,181,NULL),(60,188,NULL),(61,68,NULL),(61,83,NULL),(61,146,NULL),(61,149,NULL),(61,188,NULL),(62,68,NULL),(62,83,NULL),(62,146,NULL),(62,149,NULL),(62,188,NULL),(63,68,NULL),(63,83,NULL),(63,146,NULL),(63,149,NULL),(63,188,NULL),(64,4,NULL),(64,6,NULL),(64,44,NULL),(64,83,NULL),(64,170,NULL),(65,4,NULL),(65,6,NULL),(65,44,NULL),(65,83,NULL),(65,170,NULL),(66,4,NULL),(66,6,NULL),(66,44,NULL),(66,83,NULL),(66,170,NULL),(67,38,NULL),(67,62,NULL),(67,81,NULL),(67,147,NULL),(67,150,NULL),(67,188,NULL),(68,38,NULL),(68,62,NULL),(68,81,NULL),(68,147,NULL),(68,150,NULL),(68,188,NULL),(69,38,NULL),(69,62,NULL),(69,81,NULL),(69,147,NULL),(69,150,NULL),(69,188,NULL),(70,38,NULL),(70,62,NULL),(70,81,NULL),(70,147,NULL),(70,150,NULL),(70,188,NULL),(71,4,NULL),(71,6,NULL),(71,19,NULL),(71,38,NULL),(71,49,NULL),(71,67,NULL),(71,68,NULL),(71,80,NULL),(71,83,NULL),(71,86,NULL),(71,90,NULL),(71,102,NULL),(71,105,NULL),(71,115,NULL),(71,133,NULL),(71,141,NULL),(71,155,NULL),(72,4,NULL),(72,6,NULL),(72,19,NULL),(72,38,NULL),(72,49,NULL),(72,67,NULL),(72,68,NULL),(72,80,NULL),(72,83,NULL),(72,86,NULL),(72,90,NULL),(72,102,NULL),(72,105,NULL),(72,115,NULL),(72,133,NULL),(72,141,NULL),(72,155,NULL),(73,4,NULL),(73,6,NULL),(73,19,NULL),(73,38,NULL),(73,49,NULL),(73,67,NULL),(73,68,NULL),(73,80,NULL),(73,83,NULL),(73,86,NULL),(73,90,NULL),(73,102,NULL),(73,105,NULL),(73,115,NULL),(73,133,NULL),(73,141,NULL),(73,155,NULL),(74,8,NULL),(74,14,NULL),(74,19,NULL),(74,38,NULL),(74,66,NULL),(74,72,NULL),(74,82,NULL),(74,88,NULL),(74,92,NULL),(74,105,NULL),(74,140,NULL),(74,155,NULL),(74,175,NULL),(75,8,NULL),(75,14,NULL),(75,19,NULL),(75,38,NULL),(75,66,NULL),(75,72,NULL),(75,82,NULL),(75,88,NULL),(75,92,NULL),(75,105,NULL),(75,140,NULL),(75,155,NULL),(75,175,NULL),(76,8,NULL),(76,14,NULL),(76,19,NULL),(76,38,NULL),(76,66,NULL),(76,72,NULL),(76,82,NULL),(76,88,NULL),(76,92,NULL),(76,105,NULL),(76,140,NULL),(76,155,NULL),(76,175,NULL),(77,24,NULL),(77,36,NULL),(77,68,NULL),(77,83,NULL),(77,95,NULL),(77,100,NULL),(77,109,NULL),(77,122,NULL),(77,124,NULL),(77,135,NULL),(77,149,NULL),(77,155,NULL),(77,177,NULL),(77,193,NULL),(78,24,NULL),(78,36,NULL),(78,68,NULL),(78,83,NULL),(78,95,NULL),(78,100,NULL),(78,109,NULL),(78,122,NULL),(78,124,NULL),(78,135,NULL),(78,149,NULL),(78,155,NULL),(78,177,NULL),(78,193,NULL),(79,24,NULL),(79,36,NULL),(79,68,NULL),(79,83,NULL),(79,95,NULL),(79,100,NULL),(79,109,NULL),(79,122,NULL),(79,124,NULL),(79,135,NULL),(79,149,NULL),(79,155,NULL),(79,177,NULL),(79,193,NULL),(80,41,NULL),(80,77,NULL),(80,81,NULL),(80,109,NULL),(81,41,NULL),(81,77,NULL),(81,81,NULL),(81,109,NULL),(82,6,NULL),(82,18,NULL),(82,22,NULL),(82,45,NULL),(82,60,NULL),(82,83,NULL),(82,109,NULL),(82,114,NULL),(82,126,NULL),(82,133,NULL),(82,149,NULL),(82,181,NULL),(82,187,NULL),(82,191,NULL),(83,6,NULL),(83,18,NULL),(83,22,NULL),(83,45,NULL),(83,60,NULL),(83,83,NULL),(83,109,NULL),(83,114,NULL),(83,126,NULL),(83,133,NULL),(83,149,NULL),(83,181,NULL),(83,187,NULL),(83,191,NULL),(84,19,NULL),(84,38,NULL),(84,78,NULL),(84,81,NULL),(84,114,NULL),(84,145,NULL),(84,188,NULL),(85,19,NULL),(85,38,NULL),(85,78,NULL),(85,81,NULL),(85,114,NULL),(85,145,NULL),(85,188,NULL),(86,5,NULL),(86,6,NULL),(86,19,NULL),(86,24,NULL),(86,63,NULL),(86,65,NULL),(86,80,NULL),(86,83,NULL),(86,97,NULL),(86,100,NULL),(86,103,NULL),(86,123,NULL),(86,133,NULL),(86,155,NULL),(86,163,NULL),(86,176,NULL),(86,181,NULL),(86,183,NULL),(86,188,NULL),(86,193,NULL),(87,5,NULL),(87,6,NULL),(87,19,NULL),(87,24,NULL),(87,63,NULL),(87,65,NULL),(87,80,NULL),(87,83,NULL),(87,97,NULL),(87,100,NULL),(87,103,NULL),(87,123,NULL),(87,133,NULL),(87,155,NULL),(87,163,NULL),(87,176,NULL),(87,181,NULL),(87,183,NULL),(87,188,NULL),(87,193,NULL),(88,5,NULL),(88,6,NULL),(88,19,NULL),(88,24,NULL),(88,63,NULL),(88,65,NULL),(88,80,NULL),(88,83,NULL),(88,97,NULL),(88,100,NULL),(88,103,NULL),(88,123,NULL),(88,133,NULL),(88,155,NULL),(88,163,NULL),(88,176,NULL),(88,181,NULL),(88,183,NULL),(88,188,NULL),(88,193,NULL),(89,6,NULL),(89,34,NULL),(89,84,NULL),(89,89,NULL),(89,108,NULL),(89,133,NULL),(90,6,NULL),(90,34,NULL),(90,84,NULL),(90,89,NULL),(90,108,NULL),(90,133,NULL),(91,6,NULL),(91,34,NULL),(91,84,NULL),(91,89,NULL),(91,108,NULL),(91,133,NULL),(92,6,NULL),(92,34,NULL),(92,128,NULL),(92,152,NULL),(92,155,NULL),(92,158,NULL),(92,175,NULL),(92,181,NULL),(92,183,NULL),(93,6,NULL),(93,34,NULL),(93,128,NULL),(93,152,NULL),(93,155,NULL),(93,158,NULL),(93,175,NULL),(93,181,NULL),(93,183,NULL),(94,6,NULL),(94,34,NULL),(94,128,NULL),(94,152,NULL),(94,155,NULL),(94,158,NULL),(94,175,NULL),(94,181,NULL),(94,183,NULL),(95,6,NULL),(95,34,NULL),(95,128,NULL),(95,152,NULL),(95,155,NULL),(95,158,NULL),(95,175,NULL),(95,181,NULL),(95,183,NULL),(96,6,NULL),(96,34,NULL),(96,128,NULL),(96,152,NULL),(96,155,NULL),(96,158,NULL),(96,175,NULL),(96,181,NULL),(96,183,NULL),(97,30,NULL),(97,53,NULL),(97,165,NULL),(97,172,NULL),(97,173,NULL),(97,175,NULL),(97,181,NULL),(97,191,NULL),(98,30,NULL),(98,53,NULL),(98,165,NULL),(98,172,NULL),(98,173,NULL),(98,175,NULL),(98,181,NULL),(98,191,NULL),(99,30,NULL),(99,53,NULL),(99,165,NULL),(99,172,NULL),(99,173,NULL),(99,175,NULL),(99,181,NULL),(99,191,NULL),(100,30,NULL),(100,53,NULL),(100,165,NULL),(100,172,NULL),(100,173,NULL),(100,175,NULL),(100,181,NULL),(100,191,NULL),(101,30,NULL),(101,53,NULL),(101,165,NULL),(101,172,NULL),(101,173,NULL),(101,175,NULL),(101,181,NULL),(101,191,NULL),(102,18,NULL),(102,21,NULL),(102,38,NULL),(102,42,NULL),(102,46,NULL),(102,84,NULL),(102,96,NULL),(102,133,NULL),(102,138,NULL),(102,144,NULL),(102,155,NULL),(102,162,NULL),(102,175,NULL),(102,178,NULL),(102,181,NULL),(102,183,NULL),(103,18,NULL),(103,21,NULL),(103,38,NULL),(103,42,NULL),(103,46,NULL),(103,84,NULL),(103,96,NULL),(103,133,NULL),(103,138,NULL),(103,144,NULL),(103,155,NULL),(103,162,NULL),(103,175,NULL),(103,178,NULL),(103,181,NULL),(103,183,NULL),(104,18,NULL),(104,21,NULL),(104,38,NULL),(104,42,NULL),(104,46,NULL),(104,84,NULL),(104,96,NULL),(104,133,NULL),(104,138,NULL),(104,144,NULL),(104,155,NULL),(104,162,NULL),(104,175,NULL),(104,178,NULL),(104,181,NULL),(104,183,NULL),(105,18,NULL),(105,21,NULL),(105,38,NULL),(105,42,NULL),(105,46,NULL),(105,84,NULL),(105,96,NULL),(105,133,NULL),(105,138,NULL),(105,144,NULL),(105,155,NULL),(105,162,NULL),(105,175,NULL),(105,178,NULL),(105,181,NULL),(105,183,NULL),(106,18,NULL),(106,28,NULL),(106,34,NULL),(106,36,NULL),(106,48,NULL),(106,52,NULL),(106,77,NULL),(106,83,NULL),(106,86,NULL),(106,133,NULL),(106,134,NULL),(106,153,NULL),(106,155,NULL),(106,168,NULL),(106,175,NULL),(106,181,NULL),(106,183,NULL),(107,18,NULL),(107,28,NULL),(107,34,NULL),(107,36,NULL),(107,48,NULL),(107,52,NULL),(107,77,NULL),(107,83,NULL),(107,86,NULL),(107,133,NULL),(107,134,NULL),(107,153,NULL),(107,155,NULL),(107,168,NULL),(107,175,NULL),(107,181,NULL),(107,183,NULL),(108,18,NULL),(108,28,NULL),(108,34,NULL),(108,36,NULL),(108,48,NULL),(108,52,NULL),(108,77,NULL),(108,83,NULL),(108,86,NULL),(108,133,NULL),(108,134,NULL),(108,153,NULL),(108,155,NULL),(108,168,NULL),(108,175,NULL),(108,181,NULL),(108,183,NULL),(109,18,NULL),(109,28,NULL),(109,34,NULL),(109,36,NULL),(109,48,NULL),(109,52,NULL),(109,77,NULL),(109,83,NULL),(109,86,NULL),(109,133,NULL),(109,134,NULL),(109,153,NULL),(109,155,NULL),(109,168,NULL),(109,175,NULL),(109,181,NULL),(109,183,NULL),(110,6,NULL),(110,9,NULL),(110,11,NULL),(110,19,NULL),(110,22,NULL),(110,83,NULL),(110,88,NULL),(110,90,NULL),(110,100,NULL),(110,111,NULL),(110,114,NULL),(110,122,NULL),(110,143,NULL),(110,151,NULL),(111,6,NULL),(111,9,NULL),(111,11,NULL),(111,19,NULL),(111,22,NULL),(111,83,NULL),(111,88,NULL),(111,90,NULL),(111,100,NULL),(111,111,NULL),(111,114,NULL),(111,122,NULL),(111,143,NULL),(111,151,NULL),(112,6,NULL),(112,9,NULL),(112,11,NULL),(112,19,NULL),(112,22,NULL),(112,83,NULL),(112,88,NULL),(112,90,NULL),(112,100,NULL),(112,111,NULL),(112,114,NULL),(112,122,NULL),(112,143,NULL),(112,151,NULL),(113,6,NULL),(113,9,NULL),(113,11,NULL),(113,19,NULL),(113,22,NULL),(113,83,NULL),(113,88,NULL),(113,90,NULL),(113,100,NULL),(113,111,NULL),(113,114,NULL),(113,122,NULL),(113,143,NULL),(113,151,NULL),(114,6,NULL),(114,9,NULL),(114,11,NULL),(114,19,NULL),(114,22,NULL),(114,83,NULL),(114,88,NULL),(114,90,NULL),(114,100,NULL),(114,111,NULL),(114,114,NULL),(114,122,NULL),(114,143,NULL),(114,151,NULL),(115,6,NULL),(115,18,NULL),(115,19,NULL),(115,34,NULL),(115,47,NULL),(115,83,NULL),(115,141,NULL),(115,142,NULL),(115,175,NULL),(115,177,NULL),(115,193,NULL),(116,6,NULL),(116,18,NULL),(116,19,NULL),(116,34,NULL),(116,47,NULL),(116,83,NULL),(116,141,NULL),(116,142,NULL),(116,175,NULL),(116,177,NULL),(116,193,NULL),(117,6,NULL),(117,18,NULL),(117,19,NULL),(117,34,NULL),(117,47,NULL),(117,83,NULL),(117,141,NULL),(117,142,NULL),(117,175,NULL),(117,177,NULL),(117,193,NULL),(118,6,NULL),(118,18,NULL),(118,19,NULL),(118,34,NULL),(118,47,NULL),(118,83,NULL),(118,141,NULL),(118,142,NULL),(118,175,NULL),(118,177,NULL),(118,193,NULL),(119,6,NULL),(119,18,NULL),(119,19,NULL),(119,34,NULL),(119,47,NULL),(119,83,NULL),(119,141,NULL),(119,142,NULL),(119,175,NULL),(119,177,NULL),(119,193,NULL),(120,21,NULL),(120,59,NULL),(120,155,NULL),(120,175,NULL),(120,180,NULL),(120,181,NULL),(120,182,NULL),(121,21,NULL),(121,59,NULL),(121,155,NULL),(121,175,NULL),(121,180,NULL),(121,181,NULL),(121,182,NULL),(122,21,NULL),(122,59,NULL),(122,155,NULL),(122,175,NULL),(122,180,NULL),(122,181,NULL),(122,182,NULL),(123,21,NULL),(123,59,NULL),(123,155,NULL),(123,175,NULL),(123,180,NULL),(123,181,NULL),(123,182,NULL),(124,16,NULL),(124,26,NULL),(124,31,NULL),(124,54,NULL),(124,74,NULL),(124,86,NULL),(124,89,NULL),(124,129,NULL),(124,131,NULL),(124,148,NULL),(124,149,NULL),(124,185,NULL),(125,16,NULL),(125,26,NULL),(125,31,NULL),(125,54,NULL),(125,74,NULL),(125,86,NULL),(125,89,NULL),(125,129,NULL),(125,131,NULL),(125,148,NULL),(125,149,NULL),(125,185,NULL),(126,16,NULL),(126,26,NULL),(126,31,NULL),(126,54,NULL),(126,74,NULL),(126,86,NULL),(126,89,NULL),(126,129,NULL),(126,131,NULL),(126,148,NULL),(126,149,NULL),(126,185,NULL),(127,16,NULL),(127,26,NULL),(127,31,NULL),(127,54,NULL),(127,74,NULL),(127,86,NULL),(127,89,NULL),(127,129,NULL),(127,131,NULL),(127,148,NULL),(127,149,NULL),(127,185,NULL),(128,16,NULL),(128,26,NULL),(128,31,NULL),(128,54,NULL),(128,74,NULL),(128,86,NULL),(128,89,NULL),(128,129,NULL),(128,131,NULL),(128,148,NULL),(128,149,NULL),(128,185,NULL),(129,23,NULL),(129,60,NULL),(129,112,NULL),(129,127,NULL),(129,138,NULL),(129,154,NULL),(129,161,NULL),(130,23,NULL),(130,60,NULL),(130,112,NULL),(130,127,NULL),(130,138,NULL),(130,154,NULL),(130,161,NULL),(131,23,NULL),(131,60,NULL),(131,112,NULL),(131,127,NULL),(131,138,NULL),(131,154,NULL),(131,161,NULL),(132,23,NULL),(132,60,NULL),(132,112,NULL),(132,127,NULL),(132,138,NULL),(132,154,NULL),(132,161,NULL),(133,6,NULL),(133,17,NULL),(133,66,NULL),(133,88,NULL),(133,118,NULL),(133,133,NULL),(134,6,NULL),(134,17,NULL),(134,66,NULL),(134,88,NULL),(134,118,NULL),(134,133,NULL),(135,6,NULL),(135,17,NULL),(135,66,NULL),(135,88,NULL),(135,118,NULL),(135,133,NULL),(136,6,NULL),(136,17,NULL),(136,66,NULL),(136,88,NULL),(136,118,NULL),(136,133,NULL),(137,6,NULL),(137,17,NULL),(137,66,NULL),(137,88,NULL),(137,118,NULL),(137,133,NULL),(138,3,NULL),(138,34,NULL),(138,38,NULL),(138,60,NULL),(138,117,NULL),(138,125,NULL),(138,155,NULL),(138,179,NULL),(139,3,NULL),(139,34,NULL),(139,38,NULL),(139,60,NULL),(139,117,NULL),(139,125,NULL),(139,155,NULL),(139,179,NULL),(140,3,NULL),(140,34,NULL),(140,38,NULL),(140,60,NULL),(140,117,NULL),(140,125,NULL),(140,155,NULL),(140,179,NULL),(141,3,NULL),(141,34,NULL),(141,38,NULL),(141,60,NULL),(141,117,NULL),(141,125,NULL),(141,155,NULL),(141,179,NULL),(142,3,NULL),(142,34,NULL),(142,38,NULL),(142,60,NULL),(142,117,NULL),(142,125,NULL),(142,155,NULL),(142,179,NULL),(143,7,NULL),(143,8,NULL),(143,38,NULL),(143,58,NULL),(143,83,NULL),(143,154,NULL),(144,7,NULL),(144,8,NULL),(144,38,NULL),(144,58,NULL),(144,83,NULL),(144,154,NULL),(145,7,NULL),(145,8,NULL),(145,38,NULL),(145,58,NULL),(145,83,NULL),(145,154,NULL),(146,7,NULL),(146,21,NULL),(146,38,NULL),(146,55,NULL),(146,109,NULL),(146,154,NULL),(146,192,NULL),(147,7,NULL),(147,21,NULL),(147,38,NULL),(147,55,NULL),(147,109,NULL),(147,154,NULL),(147,192,NULL),(148,7,NULL),(148,21,NULL),(148,38,NULL),(148,55,NULL),(148,109,NULL),(148,154,NULL),(148,192,NULL),(149,18,NULL),(149,43,NULL),(149,86,NULL),(149,88,NULL),(149,175,NULL),(149,181,NULL),(150,18,NULL),(150,43,NULL),(150,86,NULL),(150,88,NULL),(150,175,NULL),(150,181,NULL),(151,18,NULL),(151,43,NULL),(151,86,NULL),(151,88,NULL),(151,175,NULL),(151,181,NULL),(152,4,NULL),(152,19,NULL),(152,61,NULL),(152,83,NULL),(152,95,NULL),(152,106,NULL),(152,155,NULL),(152,169,NULL),(152,188,NULL),(153,4,NULL),(153,19,NULL),(153,61,NULL),(153,83,NULL),(153,95,NULL),(153,106,NULL),(153,155,NULL),(153,169,NULL),(153,188,NULL),(154,4,NULL),(154,19,NULL),(154,61,NULL),(154,83,NULL),(154,95,NULL),(154,106,NULL),(154,155,NULL),(154,169,NULL),(154,188,NULL),(155,38,NULL),(155,86,NULL),(155,88,NULL),(155,122,NULL),(155,181,NULL),(155,188,NULL),(155,193,NULL),(156,38,NULL),(156,86,NULL),(156,88,NULL),(156,122,NULL),(156,181,NULL),(156,188,NULL),(156,193,NULL),(157,38,NULL),(157,86,NULL),(157,88,NULL),(157,122,NULL),(157,181,NULL),(157,188,NULL),(157,193,NULL),(158,49,NULL),(158,85,NULL),(158,109,NULL),(158,115,NULL),(158,181,NULL),(158,191,NULL),(159,49,NULL),(159,85,NULL),(159,109,NULL),(159,115,NULL),(159,181,NULL),(159,191,NULL),(160,49,NULL),(160,85,NULL),(160,109,NULL),(160,115,NULL),(160,181,NULL),(160,191,NULL),(161,6,NULL),(161,49,NULL),(161,85,NULL),(161,109,NULL),(161,115,NULL),(161,191,NULL),(162,6,NULL),(162,49,NULL),(162,85,NULL),(162,109,NULL),(162,115,NULL),(162,191,NULL),(163,6,NULL),(163,49,NULL),(163,85,NULL),(163,109,NULL),(163,115,NULL),(163,191,NULL),(164,15,NULL),(164,56,NULL),(164,87,NULL),(164,133,NULL),(164,154,NULL),(165,15,NULL),(165,56,NULL),(165,87,NULL),(165,133,NULL),(165,154,NULL),(166,15,NULL),(166,56,NULL),(166,87,NULL),(166,133,NULL),(166,154,NULL),(167,6,NULL),(167,29,NULL),(167,128,NULL),(167,178,NULL),(167,181,NULL),(167,184,NULL),(168,6,NULL),(168,29,NULL),(168,128,NULL),(168,178,NULL),(168,181,NULL),(168,184,NULL),(169,6,NULL),(169,29,NULL),(169,128,NULL),(169,178,NULL),(169,181,NULL),(169,184,NULL),(170,29,NULL),(170,32,NULL),(170,33,NULL),(170,38,NULL),(170,70,NULL),(170,99,NULL),(170,109,NULL),(170,184,NULL),(171,29,NULL),(171,32,NULL),(171,33,NULL),(171,38,NULL),(171,70,NULL),(171,99,NULL),(171,109,NULL),(171,184,NULL),(172,29,NULL),(172,32,NULL),(172,33,NULL),(172,38,NULL),(172,70,NULL),(172,99,NULL),(172,109,NULL),(172,184,NULL),(173,2,NULL),(173,5,NULL),(173,19,NULL),(173,95,NULL),(173,109,NULL),(173,121,NULL),(173,191,NULL),(174,2,NULL),(174,5,NULL),(174,19,NULL),(174,95,NULL),(174,109,NULL),(174,121,NULL),(174,191,NULL),(175,2,NULL),(175,5,NULL),(175,19,NULL),(175,95,NULL),(175,109,NULL),(175,121,NULL),(175,191,NULL),(176,10,NULL),(176,12,NULL),(176,19,NULL),(176,20,NULL),(176,24,NULL),(176,38,NULL),(176,90,NULL),(176,107,NULL),(176,109,NULL),(176,118,NULL),(176,133,NULL),(176,140,NULL),(176,141,NULL),(177,10,NULL),(177,12,NULL),(177,19,NULL),(177,20,NULL),(177,24,NULL),(177,38,NULL),(177,90,NULL),(177,107,NULL),(177,109,NULL),(177,118,NULL),(177,133,NULL),(177,140,NULL),(177,141,NULL),(178,10,NULL),(178,12,NULL),(178,19,NULL),(178,20,NULL),(178,24,NULL),(178,38,NULL),(178,90,NULL),(178,107,NULL),(178,109,NULL),(178,118,NULL),(178,133,NULL),(178,140,NULL),(178,141,NULL),(179,10,NULL),(179,12,NULL),(179,19,NULL),(179,20,NULL),(179,24,NULL),(179,38,NULL),(179,90,NULL),(179,107,NULL),(179,109,NULL),(179,118,NULL),(179,133,NULL),(179,140,NULL),(179,141,NULL),(180,10,NULL),(180,12,NULL),(180,19,NULL),(180,20,NULL),(180,24,NULL),(180,38,NULL),(180,90,NULL),(180,107,NULL),(180,109,NULL),(180,118,NULL),(180,133,NULL),(180,140,NULL),(180,141,NULL),(181,10,NULL),(181,12,NULL),(181,19,NULL),(181,20,NULL),(181,24,NULL),(181,38,NULL),(181,90,NULL),(181,107,NULL),(181,109,NULL),(181,118,NULL),(181,133,NULL),(181,140,NULL),(181,141,NULL),(182,6,NULL),(182,19,NULL),(182,24,NULL),(182,71,NULL),(182,90,NULL),(182,94,NULL),(182,109,NULL),(182,133,NULL),(182,134,NULL),(182,141,NULL),(182,149,NULL),(182,155,NULL),(182,168,NULL),(182,184,NULL),(182,193,NULL),(183,6,NULL),(183,19,NULL),(183,24,NULL),(183,71,NULL),(183,90,NULL),(183,94,NULL),(183,109,NULL),(183,133,NULL),(183,134,NULL),(183,141,NULL),(183,149,NULL),(183,155,NULL),(183,168,NULL),(183,184,NULL),(183,193,NULL),(184,6,NULL),(184,19,NULL),(184,24,NULL),(184,71,NULL),(184,90,NULL),(184,94,NULL),(184,109,NULL),(184,133,NULL),(184,134,NULL),(184,141,NULL),(184,149,NULL),(184,155,NULL),(184,168,NULL),(184,184,NULL),(184,193,NULL),(185,6,NULL),(185,19,NULL),(185,24,NULL),(185,71,NULL),(185,90,NULL),(185,94,NULL),(185,109,NULL),(185,133,NULL),(185,134,NULL),(185,141,NULL),(185,149,NULL),(185,155,NULL),(185,168,NULL),(185,184,NULL),(185,193,NULL),(186,6,NULL),(186,19,NULL),(186,24,NULL),(186,71,NULL),(186,90,NULL),(186,94,NULL),(186,109,NULL),(186,133,NULL),(186,134,NULL),(186,141,NULL),(186,149,NULL),(186,155,NULL),(186,168,NULL),(186,184,NULL),(186,193,NULL),(187,7,NULL),(187,81,NULL),(187,91,NULL),(187,155,NULL),(187,185,NULL),(188,7,NULL),(188,81,NULL),(188,91,NULL),(188,155,NULL),(188,185,NULL),(189,19,NULL),(189,24,NULL),(189,64,NULL),(189,73,NULL),(189,100,NULL),(189,109,NULL),(189,139,NULL),(189,155,NULL),(190,19,NULL),(190,24,NULL),(190,64,NULL),(190,73,NULL),(190,100,NULL),(190,109,NULL),(190,139,NULL),(190,155,NULL),(191,19,NULL),(191,63,NULL),(191,81,NULL),(191,100,NULL),(191,109,NULL),(191,156,NULL),(191,157,NULL),(191,160,NULL),(191,192,NULL),(192,19,NULL),(192,63,NULL),(192,81,NULL),(192,100,NULL),(192,109,NULL),(192,156,NULL),(192,157,NULL),(192,160,NULL),(192,192,NULL),(193,11,NULL),(193,38,NULL),(193,64,NULL),(193,90,NULL),(193,109,NULL),(193,128,NULL),(193,141,NULL),(193,155,NULL),(193,159,NULL),(194,11,NULL),(194,38,NULL),(194,64,NULL),(194,90,NULL),(194,109,NULL),(194,128,NULL),(194,141,NULL),(194,155,NULL),(194,159,NULL),(195,1,NULL),(195,19,NULL),(195,29,NULL),(195,38,NULL),(195,83,NULL),(195,88,NULL),(195,90,NULL),(195,126,NULL),(195,141,NULL),(195,164,NULL),(195,175,NULL),(195,183,NULL),(195,188,NULL),(196,1,NULL),(196,19,NULL),(196,29,NULL),(196,38,NULL),(196,83,NULL),(196,88,NULL),(196,90,NULL),(196,126,NULL),(196,141,NULL),(196,164,NULL),(196,175,NULL),(196,183,NULL),(196,188,NULL),(197,7,NULL),(197,19,NULL),(197,22,NULL),(197,49,NULL),(197,100,NULL),(197,109,NULL),(197,155,NULL),(197,183,NULL),(197,189,NULL),(198,7,NULL),(198,19,NULL),(198,22,NULL),(198,49,NULL),(198,100,NULL),(198,109,NULL),(198,155,NULL),(198,183,NULL),(198,189,NULL),(199,10,NULL),(199,38,NULL),(199,60,NULL),(199,98,NULL),(199,99,NULL),(199,109,NULL),(199,110,NULL),(199,127,NULL),(199,128,NULL),(199,132,NULL),(199,133,NULL),(199,154,NULL),(199,177,NULL),(200,10,NULL),(200,38,NULL),(200,60,NULL),(200,98,NULL),(200,99,NULL),(200,109,NULL),(200,110,NULL),(200,127,NULL),(200,128,NULL),(200,132,NULL),(200,133,NULL),(200,154,NULL),(200,177,NULL),(201,10,NULL),(201,18,NULL),(201,34,NULL),(201,42,NULL),(201,66,NULL),(201,77,NULL),(201,83,NULL),(201,133,NULL),(201,141,NULL),(201,155,NULL),(201,171,NULL),(201,174,NULL),(201,175,NULL),(201,181,NULL),(202,10,NULL),(202,18,NULL),(202,34,NULL),(202,42,NULL),(202,66,NULL),(202,77,NULL),(202,83,NULL),(202,133,NULL),(202,141,NULL),(202,155,NULL),(202,171,NULL),(202,174,NULL),(202,175,NULL),(202,181,NULL),(203,6,NULL),(203,19,NULL),(203,37,NULL),(203,39,NULL),(203,95,NULL),(203,100,NULL),(203,109,NULL),(203,136,NULL),(203,141,NULL),(203,145,NULL),(203,181,NULL),(204,6,NULL),(204,19,NULL),(204,37,NULL),(204,39,NULL),(204,95,NULL),(204,100,NULL),(204,109,NULL),(204,136,NULL),(204,141,NULL),(204,145,NULL),(204,181,NULL),(205,19,NULL),(205,39,NULL),(205,60,NULL),(205,67,NULL),(205,93,NULL),(205,110,NULL),(205,128,NULL),(205,133,NULL),(205,155,NULL),(205,165,NULL),(205,175,NULL),(206,19,NULL),(206,39,NULL),(206,60,NULL),(206,67,NULL),(206,93,NULL),(206,110,NULL),(206,128,NULL),(206,133,NULL),(206,155,NULL),(206,165,NULL),(206,175,NULL),(207,8,NULL),(207,19,NULL),(207,25,NULL),(207,38,NULL),(207,39,NULL),(207,66,NULL),(207,141,NULL),(207,158,NULL),(207,183,NULL),(208,8,NULL),(208,19,NULL),(208,25,NULL),(208,38,NULL),(208,39,NULL),(208,66,NULL),(208,141,NULL),(208,158,NULL),(208,183,NULL);
/*!40000 ALTER TABLE `Fragrance_Has_Note` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Fragrance_Ingredient`
--

DROP TABLE IF EXISTS `Fragrance_Ingredient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Fragrance_Ingredient` (
  `Ingredient_ID` int NOT NULL AUTO_INCREMENT,
  `Ingredient_Name` varchar(60) NOT NULL,
  `Is_Natural` tinyint(1) NOT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Ingredient_ID`),
  UNIQUE KEY `Ingredient_Name` (`Ingredient_Name`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Fragrance_Ingredient`
--

LOCK TABLES `Fragrance_Ingredient` WRITE;
/*!40000 ALTER TABLE `Fragrance_Ingredient` DISABLE KEYS */;
INSERT INTO `Fragrance_Ingredient` VALUES (1,'Ambroxan',0,'Ambergris-like woody amber molecule'),(2,'Hedione',0,'Transparent jasmine-like molecule'),(3,'Iso E Super',0,'Smooth cedar-like woody molecule'),(4,'Aldehydes',0,'Sparkling, soapy top-note molecules'),(5,'Ethyl Maltol',0,'Caramelized sugar, cotton-candy sweetness'),(6,'Safraleine',0,'Saffron-like leathery molecule'),(7,'Calabrian Bergamot Oil',1,'Citrus peel oil from Calabria, Italy'),(8,'Jasmine Absolute',1,'Extracted from jasmine flowers'),(9,'Rose Absolute',1,'Extracted from rose petals'),(10,'Ylang-Ylang Oil',1,'Distilled from ylang-ylang flowers'),(11,'Patchouli Oil',1,'Distilled from patchouli leaves'),(12,'Vetiver Oil',1,'Distilled from vetiver roots'),(13,'Birch Tar',1,'Smoky, leathery tar from birch bark'),(14,'Cedarwood Oil',1,'Distilled from cedar wood'),(15,'Lavender Oil',1,'Distilled from lavender flowers'),(16,'Vanilla Absolute',1,'Extracted from cured vanilla pods'),(17,'Tobacco Absolute',1,'Extracted from cured tobacco leaves');
/*!40000 ALTER TABLE `Fragrance_Ingredient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Fragrance_Note`
--

DROP TABLE IF EXISTS `Fragrance_Note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Fragrance_Note` (
  `Note_ID` int NOT NULL AUTO_INCREMENT,
  `Note_Name` varchar(45) NOT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Note_ID`),
  UNIQUE KEY `Note_Name` (`Note_Name`)
) ENGINE=InnoDB AUTO_INCREMENT=194 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Fragrance_Note`
--

LOCK TABLES `Fragrance_Note` WRITE;
/*!40000 ALTER TABLE `Fragrance_Note` DISABLE KEYS */;
INSERT INTO `Fragrance_Note` VALUES (1,'Absinthe',NULL),(2,'African Orange Flower',NULL),(3,'Akigalawood',NULL),(4,'Aldehydes',NULL),(5,'Amalfi Lemon',NULL),(6,'Amber',NULL),(7,'Ambergris',NULL),(8,'Amberwood',NULL),(9,'Ambrette',NULL),(10,'Ambroxan',NULL),(11,'Angelica',NULL),(12,'Apple',NULL),(13,'Apricot',NULL),(14,'Artemisia',NULL),(15,'Atlas Cedar',NULL),(16,'Balsamic Notes',NULL),(17,'Basil',NULL),(18,'Benzoin',NULL),(19,'Bergamot',NULL),(20,'Birch',NULL),(21,'Bitter Almond',NULL),(22,'Bitter Orange',NULL),(23,'Black Cherry',NULL),(24,'Black Currant',NULL),(25,'Black Currant Bud',NULL),(26,'Black Pepper',NULL),(27,'Blackberry',NULL),(28,'Blood Orange',NULL),(29,'Bulgarian Rose',NULL),(30,'Cacao',NULL),(31,'Cade',NULL),(32,'Calabrian Bergamot',NULL),(33,'California Orange',NULL),(34,'Cardamom',NULL),(35,'Carnation',NULL),(36,'Cashmeran',NULL),(37,'Cashmere Wood',NULL),(38,'Cedar',NULL),(39,'Centifolia Rose',NULL),(40,'Chamomile',NULL),(41,'Cherry Blossom',NULL),(42,'Cinnamon',NULL),(43,'Cinnamon Leaf',NULL),(44,'Citron',NULL),(45,'Citrus',NULL),(46,'Cloves',NULL),(47,'Coconut',NULL),(48,'Cognac',NULL),(49,'Coriander',NULL),(50,'Cumin',NULL),(51,'Damask Rose',NULL),(52,'Davana',NULL),(53,'Dried Fruits',NULL),(54,'Ebony',NULL),(55,'Egyptian Jasmine',NULL),(56,'Elemi',NULL),(57,'Fig Leaf',NULL),(58,'Fir Resin',NULL),(59,'Floral Notes',NULL),(60,'Frankincense',NULL),(61,'Freesia',NULL),(62,'Fruits',NULL),(63,'Fruity Notes',NULL),(64,'Galbanum',NULL),(65,'Gardenia',NULL),(66,'Geranium',NULL),(67,'Ginger',NULL),(68,'Grapefruit',NULL),(69,'Grapefruit Blossom',NULL),(70,'Grasse Rose',NULL),(71,'Green Apple',NULL),(72,'Green Notes',NULL),(73,'Green Tea',NULL),(74,'Guaiac Wood',NULL),(75,'Haitian Vetiver',NULL),(76,'Hawthorn',NULL),(77,'Heliotrope',NULL),(78,'Honey',NULL),(79,'Honeysuckle',NULL),(80,'Incense',NULL),(81,'Iris',NULL),(82,'Iso E Super',NULL),(83,'Jasmine',NULL),(84,'Jasmine Sambac',NULL),(85,'Juniper Berry',NULL),(86,'Labdanum',NULL),(87,'Laotian Oud',NULL),(88,'Lavender',NULL),(89,'Leather',NULL),(90,'Lemon',NULL),(91,'Lemon Verbena',NULL),(92,'Lemon Zest',NULL),(93,'Licorice',NULL),(94,'Lilac',NULL),(95,'Lily of the Valley',NULL),(96,'Liquor',NULL),(97,'Lotus',NULL),(98,'Madagascar Vanilla',NULL),(99,'Magnolia',NULL),(100,'Mandarin Orange',NULL),(101,'May Rose',NULL),(102,'Melon',NULL),(103,'Mexican Chocolate',NULL),(104,'Mimosa',NULL),(105,'Mint',NULL),(106,'Mock Orange',NULL),(107,'Moroccan Jasmine',NULL),(108,'Moss',NULL),(109,'Musk',NULL),(110,'Myrrh',NULL),(111,'Myrtle',NULL),(112,'Nagarmotha',NULL),(113,'Narcissus',NULL),(114,'Neroli',NULL),(115,'Nutmeg',NULL),(116,'Nutmeg Flower',NULL),(117,'Oak',NULL),(118,'Oakmoss',NULL),(119,'Olibanum',NULL),(120,'Opoponax',NULL),(121,'Orange',NULL),(122,'Orange Blossom',NULL),(123,'Orchid',NULL),(124,'Orris',NULL),(125,'Orris Butter',NULL),(126,'Orris Root',NULL),(127,'Osmanthus',NULL),(128,'Oud',NULL),(129,'Palo Santo',NULL),(130,'Papua New Guinean Vanilla',NULL),(131,'Papyrus',NULL),(132,'Passionfruit',NULL),(133,'Patchouli',NULL),(134,'Peach',NULL),(135,'Pear',NULL),(136,'Peony',NULL),(137,'Pepper',NULL),(138,'Peru Balsam',NULL),(139,'Petitgrain',NULL),(140,'Pineapple',NULL),(141,'Pink Pepper',NULL),(142,'Pistachio',NULL),(143,'Pittosporum',NULL),(144,'Plum',NULL),(145,'Powdery Notes',NULL),(146,'Quince',NULL),(147,'Raspberry',NULL),(148,'Resins',NULL),(149,'Rose',NULL),(150,'Rose Geranium',NULL),(151,'Rosemary',NULL),(152,'Rosewood',NULL),(153,'Rum',NULL),(154,'Saffron',NULL),(155,'Sandalwood',NULL),(156,'Sea Notes',NULL),(157,'Sea Salt',NULL),(158,'Sichuan Pepper',NULL),(159,'Sicilian Bergamot',NULL),(160,'Sicilian Lemon',NULL),(161,'Smoked Wood',NULL),(162,'Sour Cherry',NULL),(163,'Spices',NULL),(164,'Spicy Mint',NULL),(165,'Spicy Notes',NULL),(166,'Star Anise',NULL),(167,'Star Jasmine',NULL),(168,'Styrax',NULL),(169,'Sweet Pea',NULL),(170,'Teak Wood',NULL),(171,'Tobacco',NULL),(172,'Tobacco Blossom',NULL),(173,'Tobacco Leaf',NULL),(174,'Tolu Balsam',NULL),(175,'Tonka Bean',NULL),(176,'Truffle',NULL),(177,'Tuberose',NULL),(178,'Turkish Rose',NULL),(179,'Turmeric',NULL),(180,'Ultravanil',NULL),(181,'Vanilla',NULL),(182,'Vanilla Absolute',NULL),(183,'Vetiver',NULL),(184,'Violet',NULL),(185,'Violet Leaf',NULL),(186,'Virginia Cedar',NULL),(187,'White Chocolate',NULL),(188,'White Musk',NULL),(189,'White Pepper',NULL),(190,'Woodland Strawberry',NULL),(191,'Woods',NULL),(192,'Woody Notes',NULL),(193,'Ylang-Ylang',NULL);
/*!40000 ALTER TABLE `Fragrance_Note` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Perfumer`
--

DROP TABLE IF EXISTS `Perfumer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Perfumer` (
  `Person_ID` int NOT NULL,
  PRIMARY KEY (`Person_ID`),
  CONSTRAINT `perfumer_ibfk_1` FOREIGN KEY (`Person_ID`) REFERENCES `Person` (`Person_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Perfumer`
--

LOCK TABLES `Perfumer` WRITE;
/*!40000 ALTER TABLE `Perfumer` DISABLE KEYS */;
INSERT INTO `Perfumer` VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),(21),(22);
/*!40000 ALTER TABLE `Perfumer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Person`
--

DROP TABLE IF EXISTS `Person`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Person` (
  `Person_ID` int NOT NULL AUTO_INCREMENT,
  `First_Name` varchar(45) NOT NULL,
  `Last_Name` varchar(45) NOT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Country_ID` int DEFAULT NULL,
  PRIMARY KEY (`Person_ID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `Country_ID` (`Country_ID`),
  CONSTRAINT `person_ibfk_1` FOREIGN KEY (`Country_ID`) REFERENCES `Country` (`Country_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Person`
--

LOCK TABLES `Person` WRITE;
/*!40000 ALTER TABLE `Person` DISABLE KEYS */;
INSERT INTO `Person` VALUES (1,'Antoine','Maisondieu',NULL,NULL),(2,'Calice','Becker',NULL,NULL),(3,'Cécile','Zarokian',NULL,NULL),(4,'David','Apel',NULL,NULL),(5,'Edmond','Roudnitska',NULL,NULL),(6,'Emilie','Bouge',NULL,NULL),(7,'Francis','Kurkdjian',NULL,NULL),(8,'François','Demachy',NULL,NULL),(9,'Jacques','Polge',NULL,NULL),(10,'Jean-Christophe','Hérault',NULL,NULL),(11,'Jean-Louis','Sieuzac',NULL,NULL),(12,'Julien','Rasquinet',NULL,NULL),(13,'Louise','Turner',NULL,NULL),(14,'Nathalie','Gracia-Cetto',NULL,NULL),(15,'Nicolas','Bonneville',NULL,NULL),(16,'Olivier','Creed',NULL,NULL),(17,'Olivier','Gillotin',NULL,NULL),(18,'Olivier','Polge',NULL,NULL),(19,'Richard','Herpin',NULL,NULL),(20,'Rodrigo','Flores-Roux',NULL,NULL),(21,'Shyamala','Maisondieu',NULL,NULL),(22,'Sonia','Constant',NULL,NULL),(23,'Emma','Laurent','emma.laurent@example.com',1),(24,'Oliver','Hughes','oliver.hughes@example.com',2),(25,'Sophia','Martinez','sophia.martinez@example.com',3),(26,'Liam','Carter','liam.carter@example.com',3),(27,'Ines','Ferreira','ines.ferreira@example.com',4),(28,'Tiago','Almeida','tiago.almeida@example.com',4),(29,'Lucia','Garcia','lucia.garcia@example.com',5),(30,'Noah','Bennett','noah.bennett@example.com',2),(31,'Ava','Rodriguez','ava.rodriguez@example.com',3),(32,'Ethan','Brooks','ethan.brooks@example.com',3),(33,'Charlotte','Dubois','charlotte.dubois@example.com',1),(34,'James','Walker','james.walker@example.com',2),(35,'Grace','Turner','grace.turner@example.com',2),(36,'Daniel','Cooper','daniel.cooper@example.com',3),(37,'Chloe','Martin','chloe.martin@example.com',1);
/*!40000 ALTER TABLE `Person` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Purchase_Record`
--

DROP TABLE IF EXISTS `Purchase_Record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Purchase_Record` (
  `Purchase_ID` int NOT NULL AUTO_INCREMENT,
  `Purchase_Date` datetime NOT NULL,
  `Customer_ID` int NOT NULL,
  `Fragrance_ID` int NOT NULL,
  `Store_ID` int NOT NULL,
  PRIMARY KEY (`Purchase_ID`),
  KEY `Customer_ID` (`Customer_ID`),
  KEY `Fragrance_ID` (`Fragrance_ID`),
  KEY `Store_ID` (`Store_ID`),
  CONSTRAINT `purchase_record_ibfk_1` FOREIGN KEY (`Customer_ID`) REFERENCES `Customer` (`Person_ID`),
  CONSTRAINT `purchase_record_ibfk_2` FOREIGN KEY (`Fragrance_ID`) REFERENCES `Fragrance` (`Fragrance_ID`),
  CONSTRAINT `purchase_record_ibfk_3` FOREIGN KEY (`Store_ID`) REFERENCES `Store` (`Store_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Purchase_Record`
--

LOCK TABLES `Purchase_Record` WRITE;
/*!40000 ALTER TABLE `Purchase_Record` DISABLE KEYS */;
INSERT INTO `Purchase_Record` VALUES (1,'2026-06-05 11:20:00',23,2,1),(2,'2026-07-14 16:05:00',23,18,1),(3,'2026-09-02 12:40:00',23,144,1),(4,'2026-06-18 13:10:00',24,178,2),(5,'2026-08-22 17:45:00',24,178,2),(6,'2026-09-10 10:30:00',24,94,2),(7,'2026-06-27 15:00:00',25,144,3),(8,'2026-07-20 11:55:00',25,25,1),(9,'2026-08-03 18:20:00',25,88,3),(10,'2026-07-01 14:15:00',26,2,4),(11,'2026-08-15 12:00:00',26,104,4),(12,'2026-09-05 16:30:00',26,72,3),(13,'2026-09-20 10:45:00',26,54,4),(14,'2026-06-12 17:30:00',27,53,5),(15,'2026-09-12 13:25:00',27,143,5),(16,'2026-07-08 19:10:00',28,5,5),(17,'2026-08-09 12:35:00',28,72,2),(18,'2026-09-18 15:50:00',28,177,5),(19,'2026-07-25 11:05:00',29,46,5),(20,'2026-08-28 14:40:00',29,47,1),(21,'2026-11-07 14:47:02',23,2,1);
/*!40000 ALTER TABLE `Purchase_Record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Store`
--

DROP TABLE IF EXISTS `Store`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Store` (
  `Store_ID` int NOT NULL AUTO_INCREMENT,
  `City` varchar(45) NOT NULL,
  `Street` varchar(100) NOT NULL,
  `Building` varchar(45) DEFAULT NULL,
  `Floor` int DEFAULT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  `Country_ID` int NOT NULL,
  PRIMARY KEY (`Store_ID`),
  KEY `Country_ID` (`Country_ID`),
  CONSTRAINT `store_ibfk_1` FOREIGN KEY (`Country_ID`) REFERENCES `Country` (`Country_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Store`
--

LOCK TABLES `Store` WRITE;
/*!40000 ALTER TABLE `Store` DISABLE KEYS */;
INSERT INTO `Store` VALUES (1,'Paris','12 Rue du Faubourg Saint-Honore',NULL,0,'Flagship store',1),(2,'London','45 Burlington Arcade',NULL,0,NULL,2),(3,'New York','350 Madison Avenue','Madison Plaza',2,'Inside a shopping center',3),(4,'Prescott','120 N Cortez St',NULL,0,NULL,3),(5,'Lisbon','Avenida da Liberdade 180','Tivoli Forum',1,NULL,4),(6,'Los Angeles','400 S Broadway',NULL,1,NULL,3),(7,'Chicago','200 N Michigan Ave',NULL,1,NULL,3),(8,'Lyon','20 Rue de la Republique',NULL,1,NULL,1),(9,'Manchester','30 Deansgate',NULL,1,NULL,2),(10,'Porto','100 Rua de Santa Catarina',NULL,1,NULL,4);
/*!40000 ALTER TABLE `Store` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Store_Inventory`
--

DROP TABLE IF EXISTS `Store_Inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Store_Inventory` (
  `Store_ID` int NOT NULL,
  `Fragrance_ID` int NOT NULL,
  `Num_Bottles` int NOT NULL,
  PRIMARY KEY (`Store_ID`,`Fragrance_ID`),
  KEY `Fragrance_ID` (`Fragrance_ID`),
  CONSTRAINT `store_inventory_ibfk_1` FOREIGN KEY (`Store_ID`) REFERENCES `Store` (`Store_ID`),
  CONSTRAINT `store_inventory_ibfk_2` FOREIGN KEY (`Fragrance_ID`) REFERENCES `Fragrance` (`Fragrance_ID`),
  CONSTRAINT `store_inventory_chk_1` CHECK ((`Num_Bottles` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Store_Inventory`
--

LOCK TABLES `Store_Inventory` WRITE;
/*!40000 ALTER TABLE `Store_Inventory` DISABLE KEYS */;
INSERT INTO `Store_Inventory` VALUES (1,2,17),(1,18,0),(1,25,12),(1,47,10),(1,144,6),(2,2,20),(2,72,14),(2,94,4),(2,178,8),(2,188,5),(3,6,25),(3,72,18),(3,88,6),(3,99,7),(3,144,11),(3,178,9),(4,2,6),(4,54,3),(4,71,4),(4,104,0),(5,5,10),(5,46,6),(5,53,8),(5,143,5),(5,177,4),(6,1,12),(6,45,12),(6,86,12),(6,143,12),(6,176,12),(7,1,8),(7,45,8),(7,86,8),(7,143,8),(7,176,8),(8,1,6),(8,45,6),(8,86,6),(8,143,6),(8,176,6),(9,1,10),(9,45,10),(9,86,10),(9,143,10),(9,176,10),(10,1,7),(10,45,7),(10,86,7),(10,143,7),(10,176,7);
/*!40000 ALTER TABLE `Store_Inventory` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-07 15:00:17
