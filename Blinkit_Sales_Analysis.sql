create database blinkit_sales;
use blinkit_sales;

select count(*) as total_count 
from blinkit;  

 describe blinkit;
 ------------------------------------------------------------------------------------------------------------------------------------
 -- Assess data quality before conducting sales analysis.
 -- Identify missing values in important numeric columns.
-- SQL Concepts: SUM(), CASE WHEN, IS NULL.

SELECT
    SUM(CASE WHEN Item_Weight IS NULL THEN 1 ELSE 0 END) AS missing_item_weight,
    SUM(CASE WHEN Item_Visibility IS NULL THEN 1 ELSE 0 END) AS missing_item_visibility,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS missing_sales,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS missing_rating,
    SUM(CASE WHEN Outlet_Size IS NULL THEN 1 ELSE 0 END) AS missing_outlet_size
FROM blinkit;
------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose: Ensure duplicate records do not distort sales analysis.
-- SQL Concepts: GROUP BY, HAVING, COUNT().

SELECT 
    Item_Identifier,
    Item_Type,
    Outlet_Identifier,
    COUNT(*) AS record_count
FROM
    blinkit
GROUP BY Item_Identifier , Item_Type , Outlet_Identifier
HAVING COUNT(*) > 1
ORDER BY record_count DESC;
---------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose: Identify different labels used in the dataset.
-- SQL Concepts: Distinct
SELECT DISTINCT Item_Fat_Content
FROM blinkit;
-----------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose: Identify inconsistent labels and their frequency.
-- SQL Concepts: GROUP BY, COUNT(), ORDER BY.

SELECT
    Item_Fat_Content,
    COUNT(*) AS total_records
FROM blinkit
GROUP BY Item_Fat_Content
ORDER BY total_records DESC;


-- Standardize fat-content categories.
-- Business Purpose: Combine inconsistent labels.

SELECT
    CASE
        WHEN Item_Fat_Content = 'LF' THEN 'Low Fat'
        WHEN Item_Fat_Content = 'Reg' THEN 'Regular'
        ELSE Item_Fat_Content
    END AS standardized_category,
    COUNT(*) AS total_records
FROM blinkit
GROUP BY standardized_category;
-------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose: Check whether fat-content categories are missing.
SELECT *
FROM blinkit
WHERE Item_Fat_Content IS NULL
   OR Item_Fat_Content = '';
---------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose: Identify the best-performing outlet type.
-- SQL Concepts: SUM(), GROUP BY, ORDER BY

SELECT
Outlet_Type,
ROUND(SUM(Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Type
ORDER BY total_sales DESC;

-- BUSSINESS INSIGHT
-- Supermarket Type 1 generates the highest total sales at 787,549.89,
-- significantly outperforming Supermarket Type 2 (131,477.78) and Grocery Store outlets (78,131.57).
-- This indicates that Supermarket Type 1 is the largest contributor to total sales among the three outlet types analyzed.
-------------------------------------------------------------------------------------------------------------------------------------
-- Business Question: Which item types generate the highest sales?
-- Business Purpose: Identify the top revenue-generating product categories.
-- SQL Concepts: SUM(), GROUP BY, ORDER BY, LIMIT

select item_type, 
round(sum(sales), 2) as total_sales 
 from blinkit
group by item_type
order by total_sales desc
limit 5;

-- Business Insight
-- Fruits and Vegetables generate the highest total sales at 147,188.96, closely followed by Snack Foods at 144,949.13.
-- Household products rank third at 113,210.14, followed by Frozen Foods and Dairy
-- These results indicate that Fruits and Vegetables and Snack Foods are the leading sales-generating categories among the top five item types.
------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose: Compare sales across different location tiers.
-- SQL Concepts: SUM(), GROUP BY, ORDER BY

SELECT
    Outlet_Location_Type,
    ROUND(SUM(Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Location_Type
ORDER BY total_sales DESC;

--  Standardize Outlet Location Tier Labels
-- Business Purpose: Combine inconsistent tier labels for accurate reporting.
-- SQL Concepts: CASE, SUM(), GROUP BY, ORDER BY
SELECT
CASE
WHEN TRIM(Outlet_Location_Type) = 'T1' THEN 'Tier 1'
WHEN TRIM(Outlet_Location_Type) = 'T2' THEN 'Tier 2'
WHEN TRIM(Outlet_Location_Type) = 'T3' THEN 'Tier 3'
ELSE TRIM(Outlet_Location_Type)
END AS standardized_tier,
    ROUND(SUM(Sales), 2) AS total_sales
FROM blinkit
GROUP BY standardized_tier
ORDER BY total_sales DESC;
-- Business Insight:
--  Tier 2 outlets generate the highest sales (393,150.65), followed by Tier 3 and Tier 1, after standardizing inconsistent labels.
-- -------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose: Compare total sales across outlet establishment years.
-- SQL Concepts: SUM(), GROUP BY, ORDER BY

SELECT
    Outlet_Establishment_Year,
    ROUND(SUM(Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Establishment_Year
ORDER BY total_sales DESC;
-- Business Insight:
-- Outlets established in 2017 generated the highest total sales (133,103.91),
--  while outlets established in 2011 recorded the lowest (78,131.57) among the years analyzed
------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose: Compare average sales across product categories.
-- SQL Concepts: AVG(), ROUND(), GROUP BY, ORDER BY

SELECT
    Item_Type,
    ROUND(AVG(Sales), 2) AS average_sales
FROM blinkit
GROUP BY Item_Type
ORDER BY average_sales DESC;
-- Business Insight:
-- Dairy leads in average sales (149.34), narrowly outperforming Household (149.16).
-- This indicates relatively consistent average sales across the leading categories
-- with only a small difference between the top performers.
------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose: Identify which outlet size contributes the most to total sales.
-- SQL Concepts: SUM(), GROUP BY, ORDER BY

SELECT
    Outlet_Size,
    ROUND(SUM(Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Size
ORDER BY total_sales DESC;
-- Business Insight
-- Medium-sized outlets generate the highest total sales (377,181.06),closely followed by Small outlets (370,986.59).
-- High-sized outlets record the lowest sales (248,991.59),
--  indicating that larger outlet size does not necessarily translate into higher sales.
-----------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose: Compare sales contribution from Low Fat and Regular products.
-- SQL Concepts: CASE, SUM(), GROUP BY, ORDER BY

SELECT
    CASE
        WHEN TRIM(Item_Fat_Content) IN ('LF', 'Low Fat') THEN 'Low Fat'
        WHEN TRIM(Item_Fat_Content) IN ('Reg', 'Regular') THEN 'Regular'
        ELSE TRIM(Item_Fat_Content)
    END AS standardized_fat_content,
    ROUND(SUM(Sales), 2) AS total_sales
FROM blinkit
GROUP BY standardized_fat_content
ORDER BY total_sales DESC;
-- Business Insight
-- Low Fat products contribute significantly higher total sales (644,516.74) than Regular products (352,642.49),
--  indicating a stronger sales contribution from the Low Fat category in the analyzed dataset.
-----------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose:
-- Compare average ratings across product categories to identify
-- categories with stronger customer satisfaction signals.
-- SQL Concepts:AVG(), ROUND(), COUNT(), GROUP BY, ORDER BY
SELECT
Item_Type,
ROUND(AVG(Rating), 2) AS average_rating,
COUNT(*) AS total_records
FROM blinkit
WHERE Rating IS NOT NULL
GROUP BY Item_Type
ORDER BY average_rating DESC, total_records DESC;
-- Business Insight
-- Meat has the highest average rating at 4.01, based on 337 records, while Breakfast has a rating of 3.94 across 89 records
-- ratings across the reported categories are relatively close, ranging from 3.94 to 4.01, 
-- indicating limited variation in average customer ratings.
-----------------------------------------------------------------------------------------------------------------------------------
-- Q22: Item Type Contribution to Total Sales
-- Business Purpose: Identify the product categories that contribute the most
-- to overall sales and calculate their percentage contribution.

-- SQL Concepts:SUM(), ROUND(), GROUP BY, ORDER BY, Subquery

SELECT
Item_Type,
ROUND(SUM(Sales), 2) AS total_sales,
ROUND(SUM(Sales) * 100.0 /
(SELECT SUM(Sales) FROM blinkit),
2) AS sales_percentage
FROM blinkit
GROUP BY Item_Type
ORDER BY total_sales DESC;
-- Business Insight
-- Fruits and Vegetables contribute the highest share of total sales at 14.76% (147,188.96),
--  closely followed by Snack Foods at 14.54% (144,949.13).
-- Together,these two categories account for 29.30% of total sales, indicating that they are major revenue contributors in the dataset.
--------------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose:
-- Compare average sales across outlet types to identify
-- which outlet formats generate higher sales per item record.
-- SQL Concepts:AVG(), ROUND(), COUNT(), GROUP BY, ORDER BY

SELECT
Outlet_Type,ROUND(AVG(Sales), 2) AS average_sales,
COUNT(*) AS total_records,
ROUND(SUM(Sales), 2) AS total_sales
FROM blinkit
GROUP BY Outlet_Type
ORDER BY average_sales DESC;
-- Business Insight-- 
-- Supermarket Type 2 has the highest average sales per record at 141.68
-- slightly exceeding Supermarket Type 1 (141.21) and Grocery Store (140.78).
-- Supermarket Type 1 generates the highest total sales at 787,549.89, supported by 5,577 records,
--  indicating substantially greater overall sales
-------------------------------------------------------------------------------------------------------------------------------------
-- Q25: Top-Selling Products Within Each Item Type

-- Business Purpose:
-- Identify the highest-revenue products within each category
-- to support product-level performance analysis.

-- SQL Concepts:
-- CTE, SUM(), GROUP BY, ROW_NUMBER(), PARTITION BY

WITH ProductSales AS (
    SELECT
        Item_Identifier,
        Item_Type,
        ROUND(SUM(Sales), 2) AS total_sales
    FROM blinkit
    GROUP BY
        Item_Identifier,
        Item_Type
),
RankedProducts AS (
    SELECT
        Item_Identifier,
        Item_Type,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY Item_Type
            ORDER BY total_sales DESC
        ) AS product_rank
    FROM ProductSales
)
SELECT
    Item_Type,
    Item_Identifier,
    total_sales
FROM RankedProducts
WHERE product_rank = 1
ORDER BY total_sales DESC;

-- Business Insight
-- FDL58 (Snack Foods) generates the highest total sales within its category at 2,111.65, 
-- followed by FDP28 (Frozen Foods) at 2,087.85.
--  The top-performing product varies across categories, highlighting the importance of evaluating product-level sales
--  rather than relying solely on category-level performance.
-------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose:
-- Identify the highest-revenue outlet within each outlet type
-- to understand outlet-level sales performance.

-- SQL Concepts: CTE, SUM(), GROUP BY, ROW_NUMBER(), PARTITION BY

WITH OutletSales AS (
    SELECT
        Outlet_Identifier,
        Outlet_Type,
        ROUND(SUM(Sales), 2) AS total_sales
    FROM blinkit
    GROUP BY
        Outlet_Identifier,
        Outlet_Type
),
RankedOutlets AS (
    SELECT
        Outlet_Identifier,
        Outlet_Type,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY Outlet_Type
            ORDER BY total_sales DESC
        ) AS outlet_rank
    FROM OutletSales
)
SELECT
Outlet_Type,
Outlet_Identifier,
total_sales
FROM RankedOutlets
WHERE outlet_rank = 1
ORDER BY total_sales DESC;

-- Business Insight
-- Outlet OUT035 leads Supermarket Type 1 with total sales of 133,103.91, while OUT018 leads Supermarket Type 2 with 131,477.78.
--  Grocery Store OUT010 generates 78,131.57. 
--  These results identify the top-selling outlet within each format, 
--  but total sales alone do not establish outlet efficiency or profitability.
---------------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose:
-- Compare average and total sales across different
-- item visibility levels to identify sales patterns.
-- SQL Concepts: CASE, GROUP BY, COUNT(), AVG(), SUM()

SELECT
    CASE
        WHEN Item_Visibility < 0.05 THEN 'Low Visibility'
        WHEN Item_Visibility < 0.10 THEN 'Medium Visibility'
        ELSE 'High Visibility'
    END AS Visibility_Level,
    COUNT(*) AS Total_Records,
    ROUND(AVG(Sales), 2) AS Average_Sales,
    ROUND(SUM(Sales), 2) AS Total_Sales

FROM blinkit
GROUP BY
CASE
WHEN Item_Visibility < 0.05 THEN 'Low Visibility'
WHEN Item_Visibility < 0.10 THEN 'Medium Visibility'
ELSE 'High Visibility'
END
ORDER BY Average_Sales DESC;

-- Business Insights
-- Medium Visibility: Recorded the highest average sales of 145.77 across 2,117 records.
-- Low Visibility: Generated the highest total sales of 478,766.82 across 3,425 records.
-- High Visibility: Had the lowest average sales of 138.20 across 1,518 records.
-- Key Finding: Higher product visibility does not necessarily correspond to higher average sales
------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose:
-- Compare total sales, average sales, and record count
-- across standardized outlet location tiers.
-- SQL Concepts:CTE, CASE, GROUP BY, COUNT(), SUM(), AVG()

WITH Outlet_Performance AS (
SELECT
CASE
WHEN Outlet_Location_Type IN ('Tier 1', 'T1') THEN 'Tier 1'
WHEN Outlet_Location_Type IN ('Tier 2', 'T2') THEN 'Tier 2'
WHEN Outlet_Location_Type IN ('Tier 3', 'T3') THEN 'Tier 3'
ELSE Outlet_Location_Type        
END AS Location_Tier,
Sales
FROM blinkit
)
SELECT
Location_Tier, COUNT(*) AS Total_Records,
ROUND(SUM(Sales), 2) AS Total_Sales,
ROUND(AVG(Sales), 2) AS Average_Sales
FROM Outlet_Performance
GROUP BY Location_Tier
ORDER BY Total_Sales DESC;
-- Business Insights
-- Tier 2 Outlets: Generated the highest total sales of 393,150.65 across 2,785 records.
-- Tier 3 Outlets: Contributed 341,418.36 in total sales and achieved the highest average sales of 141.37 per record.
-- Tier 1 Outlets: Recorded the lowest total sales of 262,590.23 across 1,860 records.
-- Key Finding: Average sales are nearly identical across all three tiers, ranging from 141.17 to 141.37.
--  Total sales differences are primarily associated with the number of records.
-------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose:
-- Identify the top-performing item categories for each outlet type.
-- SQL Concepts:Subquery, RANK(), PARTITION BY, GROUP BY, SUM()
SELECT
Outlet_Type,Item_Type,Total_Sales,Sales_Rank
FROM (SELECT
Outlet_Type,
Item_Type,
Total_Sales,
RANK() OVER (PARTITION BY Outlet_Type
ORDER BY Total_Sales DESC) AS Sales_Rank
FROM (
SELECT
Outlet_Type,
Item_Type,
SUM(Sales) AS Total_Sales
FROM blinkit
GROUP BY Outlet_Type, Item_Type) AS Category_Sales) AS Ranked_Categories
WHERE Sales_Rank <= 3
ORDER BY Outlet_Type, Sales_Rank;
-- Business Insights
-- Grocery Stores: Fruits and Vegetables generated the highest sales at 10,789.68, 
-- followed by Snack Foods at 10,649.76 and Household products at 9,822.08.
-- Supermarket Type 1: Fruits and Vegetables led with sales of 117,431.99, followed by Snack Foods at 114,296.13 and Household products at 89,143.41.
-- Supermarket Type 2: Snack Foods ranked first at 20,003.24, followed by Fruits and Vegetables at 18,967.29 
-- and Household products at 14,244.65.
-- Key Finding: Fruits and Vegetables and Snack Foods are consistently among the top three categories across all outlet types.
--  However, Snack Foods leads in Supermarket Type 2, indicating differences in category performance by outlet format.
---------------------------------------------------------------------------------------------------------------------------------------
-- Business Purpose:
-- Identify item categories performing above or below
-- the overall average category sales
-- SQL Concepts:CTE, Subquery, GROUP BY, SUM(), AVG(), CASE

WITH Category_Sales AS (
    SELECT
        Item_Type,
        ROUND(SUM(Sales), 2) AS Total_Sales
    FROM blinkit
    GROUP BY Item_Type
),
Overall_Average AS (
    SELECT AVG(Total_Sales) AS Average_Category_Sales
    FROM Category_Sales
)
SELECT
    C.Item_Type,C.Total_Sales,
ROUND(O.Average_Category_Sales, 2) AS Average_Category_Sales,
CASE
WHEN C.Total_Sales > O.Average_Category_Sales
THEN 'Above Average'
WHEN C.Total_Sales < O.Average_Category_Sales
        THEN 'Below Average'
ELSE 'Average'
    END AS Performance_Status
FROM Category_Sales C
CROSS JOIN Overall_Average O
ORDER BY C.Total_Sales DESC;

-- Business Insights
-- Top Category: Fruits and Vegetables led with sales of 147,188.96, followed by Snack Foods at 144,949.13.
-- Above Average: 7 categories exceeded the average sales of 62,322.45.
-- Low Performers: Seafood recorded the lowest sales at 7,397.56.
-- Business Recommendations
