use scent_db;
SELECT * FROM Fragrance_Ingredient;


SELECT Fragrance.Fragrance_Name, Brand.Name,
CASE
	WHEN COUNT(Fragrance_Ingredient.Ingredient_ID) = 0 Then 'No Ingredient Data'

	WHEN SUM(CASE WHEN Fragrance_Ingredient.Is_Natural != 1 THEN 1 ELSE 0 END) = 0 THEN 'Clean Fragrance'
    
    ELSE 'Contains Synthetic Ingredients'
END AS Natural_Status
FROM Fragrance
LEFT JOIN Fragrance_Has_Ingredient ON Fragrance.Fragrance_ID = Fragrance_Has_Ingredient.Fragrance_ID
LEFT JOIN Fragrance_Ingredient on Fragrance_Has_Ingredient.Ingredient_ID = Fragrance_Ingredient.Ingredient_ID
Inner Join Brand on Brand.Brand_ID = Fragrance.Brand_ID
GROUP BY Fragrance.Fragrance_Name, Brand.Name;



