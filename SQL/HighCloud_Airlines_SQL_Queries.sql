Create DATABASE cs;
USE cs;
select * FROM mainfile;

-- =========================================
-- KPI 1 : Calendar Table
-- =========================================

DROP TABLE IF EXISTS calender;

CREATE TABLE calender (
    DateKey DATE,
    Year INT,
    Month_No INT,
    Day_No INT,
    Week_No INT,
    MonthName VARCHAR(50),
    Weekday_No INT,
    YearMonth VARCHAR(50),
    DayName VARCHAR(50),
    Quarters VARCHAR(10),
    Financial_Months VARCHAR(20),
    Financial_Quarters VARCHAR(20)
);

INSERT INTO calender
SELECT
    STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`), '%Y-%m-%d') AS DateKey,

    `Year`,

    `Month (#)`,

    `Day`,

    WEEK(STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`), '%Y-%m-%d')),

    MONTHNAME(
        STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`), '%Y-%m-%d')
    ),

    WEEKDAY(
        STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`), '%Y-%m-%d')
    ),

    CONCAT(
        `Year`,
        '-',
        MONTHNAME(
            STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`), '%Y-%m-%d')
        )
    ),

    DAYNAME(
        STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`), '%Y-%m-%d')
    ),

    CASE
        WHEN `Month (#)` BETWEEN 1 AND 3 THEN 'Q1'
        WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'Q2'
        WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END,

    CONCAT(
        'FM',
        CASE
            WHEN `Month (#)` >= 4 THEN `Month (#)` - 3
            ELSE `Month (#)` + 9
        END
    ),

    CASE
        WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN `Month (#)` BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END

FROM mainfile;

SELECT * FROM calender LIMIT 10;

-- =========================================
-- KPI 2 : Load Factor Percentage
-- Yearly Analysis
-- =========================================

SELECT 
    Year,

    SUM(`# Transported Passengers`) AS Total_Passengers,

    SUM(`# Available Seats`) AS Total_Seats,

    ROUND(
        (SUM(`# Transported Passengers`) /
        SUM(`# Available Seats`)) * 100
    ,2) AS Load_Factor_Percentage

FROM mainfile

GROUP BY Year

ORDER BY Year;
-- =========================================
-- KPI 2 : Quarterly Analysis
-- =========================================

SELECT 

    Year,

    CASE
        WHEN `Month (#)` BETWEEN 1 AND 3 THEN 'Q1'
        WHEN `Month (#)` BETWEEN 4 AND 6 THEN 'Q2'
        WHEN `Month (#)` BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END AS Quarter,

    SUM(`# Transported Passengers`) AS Total_Passengers,

    SUM(`# Available Seats`) AS Total_Seats,

    ROUND(
        (SUM(`# Transported Passengers`) /
        SUM(`# Available Seats`)) * 100
    ,2) AS Load_Factor_Percentage

FROM mainfile

GROUP BY Year, Quarter

ORDER BY Year, Quarter;
-- =========================================
-- KPI 2 : Monthly Analysis
-- =========================================
SELECT 

    Year,

    `Month (#)` AS Month_No,

    MONTHNAME(
        STR_TO_DATE(
            CONCAT('2024-', `Month (#)`, '-01'),
            '%Y-%m-%d'
        )
    ) AS Month_Name,

    SUM(`# Transported Passengers`) AS Total_Passengers,

    SUM(`# Available Seats`) AS Total_Seats,

    ROUND(
        (SUM(`# Transported Passengers`) /
        SUM(`# Available Seats`)) * 100
    ,2) AS Load_Factor_Percentage

FROM mainfile

GROUP BY Year, `Month (#)`

ORDER BY Year, `Month (#)`;
-- =========================================
-- KPI 3 : Carrier Wise Load Factor
-- =========================================

SELECT 

    `Carrier Name`,

    SUM(`# Transported Passengers`) AS Total_Passengers,

    SUM(`# Available Seats`) AS Total_Seats,

    ROUND(
        (SUM(`# Transported Passengers`) /
        SUM(`# Available Seats`)) * 100
    ,2) AS Load_Factor_Percentage

FROM mainfile

GROUP BY `Carrier Name`

ORDER BY Load_Factor_Percentage DESC;


-- =========================================
-- KPI 4 : Top 10 Carriers
-- =========================================

SELECT 

    `Carrier Name`,

    SUM(`# Transported Passengers`) AS Total_Passengers,

    ROUND(
        SUM(`# Transported Passengers`) * 100.0 /
        (SELECT SUM(`# Transported Passengers`) FROM mainfile)
    ,2) AS Percentage_Share

FROM mainfile

GROUP BY `Carrier Name`

ORDER BY Total_Passengers DESC

LIMIT 10;


-- =========================================
-- KPI 5 : Top Routes
-- =========================================

SELECT 

    `From - To City` AS Route,

    COUNT(*) AS Number_of_Flights,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM mainfile)
    ,2) AS Percentage_Share

FROM mainfile

GROUP BY `From - To City`

ORDER BY Number_of_Flights DESC

LIMIT 10;


-- =========================================
-- KPI 6 : Weekend vs Weekday Load Factor
-- =========================================

SELECT 

    CASE

        WHEN DAYOFWEEK(
            STR_TO_DATE(
                CONCAT(
                    `Year`,
                    '-',
                    `Month (#)`,
                    '-',
                    `Day`
                ),
                '%Y-%m-%d'
            )
        ) IN (1,7)

        THEN 'Weekend'

        ELSE 'Weekday'

    END AS Day_Type,

    SUM(`# Transported Passengers`) AS Total_Passengers,

    SUM(`# Available Seats`) AS Total_Seats,

    ROUND(
        (SUM(`# Transported Passengers`) /
        SUM(`# Available Seats`)) * 100
    ,2) AS Load_Factor_Percentage

FROM mainfile

GROUP BY Day_Type;


-- =========================================
-- KPI 7 : Distance Group Analysis
-- =========================================

SELECT 

    CASE

        WHEN Distance BETWEEN 0 AND 250
            THEN '0-250 KM'

        WHEN Distance BETWEEN 251 AND 500
            THEN '251-500 KM'

        WHEN Distance BETWEEN 501 AND 1000
            THEN '501-1000 KM'

        WHEN Distance BETWEEN 1001 AND 1500
            THEN '1001-1500 KM'

        WHEN Distance BETWEEN 1501 AND 2000
            THEN '1501-2000 KM'

        ELSE '2000+ KM'

    END AS Distance_Group,

    COUNT(*) AS Total_Flights

FROM mainfile

GROUP BY Distance_Group

ORDER BY Total_Flights DESC;