USE scent_db;

START Transaction;

-- Country:

INSERT IGNORE Country (Name)
Values ('United States');


-- Brand:

INSERT IGNORE Brand (Name, Country_ID)
VALUES ('Le Labo', (SELECT Country_ID FROM Country WHERE Name = 'United States'));

-- Create Fragrance Notes:

INSERT IGNORE Fragrance_Note (Note_Name) Values ('Cardamom');
INSERT IGNORE Fragrance_Note (Note_Name) Values ('Violet');
INSERT IGNORE Fragrance_Note (Note_Name) Values ('Iris');
INSERT IGNORE Fragrance_Note (Note_Name) Values ('Papyrus');
INSERT IGNORE Fragrance_Note (Note_Name) Values ('Ambroxan');
INSERT IGNORE Fragrance_Note (Note_Name) Values ('Sandalwood');
INSERT IGNORE Fragrance_Note (Note_Name) Values ('Cedarwood');
INSERT IGNORE Fragrance_Note (Note_Name) Values ('Leather');
INSERT IGNORE Fragrance_Note (Note_Name) Values ('Amber');
INSERT IGNORE Fragrance_Note (Note_Name) Values ('Musk');

-- Perfumer + Person
-- Frank Voelkl

-- Perfumer Country
INSERT IGNORE Country (Name)
Values ('Germany');

-- Person Entry
INSERT IGNORE PERSON (First_Name, Last_Name, Email, Country_ID)
VALUES ('Frank', 'Voelkl', NULL, (SELECT Country_ID FROM Country WHERE Name = 'Germany'));


SELECT * From Person;
-- Perfumer Entry
INSERT IGNORE Perfumer (Person_ID)
Values ((SELECT Person_ID FROM Person WHERE First_Name = 'Frank' AND Last_Name = 'Voelkl'));

-- Test
SELECT Person.First_Name, Person.Last_Name, Person.Person_ID FROM Perfumer
INNER JOIN Person ON PERSON.Person_ID = Perfumer.Person_ID;


SELECT * FROM FRagrance LIMIT 1;
-- Fragrance Entry
Insert IGNORE Fragrance 
(
Fragrance_Name,
Strength,
Size,
Notes,
Price,
Perfumer_ID,
Brand_ID)
Values
(
'Santal 33',
'Eau de Parfum',
'50',
"Price in USD, Size in ml",
240.00,
(SELECT Person_ID FROM Person WHERE First_Name = 'Frank' AND Last_Name = 'Voelkl'),
(SELECT Brand_ID FROM Brand WHERE Name = 'Le Labo'));

-- Test
SELECT * FROM FRAGRANCE where fragrance_Name = "Santal 33";
SELECT * FROM BRAND WHERE Name = "Le Labo";

-- Has_Note Relations
INSERT IGNORE Fragrance_Has_Note
(Fragrance_ID, Note_ID) Values
(
(SELECT Fragrance_ID FROM Fragrance WHERE fragrance_name = 'Santal 33'),
(SELECT Note_ID FROM Fragrance_Note WHERE note_Name = 'Cardamom')
);
INSERT IGNORE Fragrance_Has_Note
(Fragrance_ID, Note_ID) Values
(
(SELECT Fragrance_ID FROM Fragrance WHERE fragrance_name = 'Santal 33'),
(SELECT Note_ID FROM Fragrance_Note WHERE note_Name = 'Violet')
);
INSERT IGNORE Fragrance_Has_Note
(Fragrance_ID, Note_ID) Values
(
(SELECT Fragrance_ID FROM Fragrance WHERE fragrance_name = 'Santal 33'),
(SELECT Note_ID FROM Fragrance_Note WHERE note_Name = 'Iris')
);
INSERT IGNORE Fragrance_Has_Note
(Fragrance_ID, Note_ID) Values
(
(SELECT Fragrance_ID FROM Fragrance WHERE fragrance_name = 'Santal 33'),
(SELECT Note_ID FROM Fragrance_Note WHERE note_Name = 'Papyrus')
);
INSERT IGNORE Fragrance_Has_Note
(Fragrance_ID, Note_ID) Values
(
(SELECT Fragrance_ID FROM Fragrance WHERE fragrance_name = 'Santal 33'),
(SELECT Note_ID FROM Fragrance_Note WHERE note_Name = 'Ambroxan')
);
INSERT IGNORE Fragrance_Has_Note
(Fragrance_ID, Note_ID) Values
(
(SELECT Fragrance_ID FROM Fragrance WHERE fragrance_name = 'Santal 33'),
(SELECT Note_ID FROM Fragrance_Note WHERE note_Name = 'Cedarwood')
);
INSERT IGNORE Fragrance_Has_Note
(Fragrance_ID, Note_ID) Values
(
(SELECT Fragrance_ID FROM Fragrance WHERE fragrance_name = 'Santal 33'),
(SELECT Note_ID FROM Fragrance_Note WHERE note_Name = 'Sandalwood')
);
INSERT IGNORE Fragrance_Has_Note
(Fragrance_ID, Note_ID) Values
(
(SELECT Fragrance_ID FROM Fragrance WHERE fragrance_name = 'Santal 33'),
(SELECT Note_ID FROM Fragrance_Note WHERE note_Name = 'Leather')
);
INSERT IGNORE Fragrance_Has_Note
(Fragrance_ID, Note_ID) Values
(
(SELECT Fragrance_ID FROM Fragrance WHERE fragrance_name = 'Santal 33'),
(SELECT Note_ID FROM Fragrance_Note WHERE note_Name = 'Musk')
);
INSERT IGNORE Fragrance_Has_Note
(Fragrance_ID, Note_ID) Values
(
(SELECT Fragrance_ID FROM Fragrance WHERE fragrance_name = 'Santal 33'),
(SELECT Note_ID FROM Fragrance_Note WHERE note_Name = 'Amber')
);

COMMIT;















