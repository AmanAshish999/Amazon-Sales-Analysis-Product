/* 1.Creating DataBase Amazone*/

create DATABASE Amazon;

use Amazon;

/*2.Creating Table of Amazonesales*/

CREATE table Amazonesales (
Invoice_id VARCHAR(30) NOT NULL,
Branch VARCHAR(30) NOT NULL,
City VARCHAR(30) NOT NULL,
Customer_type VARCHAR(30) NOT NULL,
Gender VARCHAR(30) NOT NULL,
Product_line VARCHAR(30) NOT NULL,
Unit_price DECIMAL(10, 2) NOT NULL,
Quantity INT NOT NULL,
VAT FLOAT NOT NULL,
Total DECIMAL(10, 2) NOT NULL,
Dates DATE NOT NULL,
Times TIME NOT NULL,
Payment VARCHAR(10) NOT NULL,
Cogs DECIMAL(10, 2) NOT NULL,
Gross_margin_percentage FLOAT NOT NULL,
Gross_income DECIMAL(10, 2) NOT NULL,
Rating FLOAT NOT NULL
);


select * from amazonesales;

/*Feature Engineering*/

/*Add a new column named timeofday to give insight of sales in the Morning,Afternoon and Evening.*/
/* This will help answer the question on which part of the day most sales are made.*/

ALTER TABLE Amazonesales                         /*Alter is part of DDL*/
ADD COLUMN time_of_day VARCHAR(15);              /*Creating Column time_of_day*/

UPDATE Amazonesales                              /*Update is part of DML*/
SET time_of_day = CASE 
                    WHEN HOUR(Times) >= 0 AND HOUR(Times) < 12 THEN 'Morning'
                    WHEN HOUR(Times) >= 12 AND HOUR(Times) < 18 THEN 'Afternoon'
                    ELSE 'Evening'
                END;
                
/*Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri).*/
/*This will help answer the question on which week of the day each branch is busiest.*/              
    
ALTER TABLE Amazonesales
ADD COLUMN Dayname VARCHAR(10);      /*Adding new column Dayname*/

UPDATE Amazonesales
SET dayname = CASE DAYOFWEEK(Dates)
                WHEN 1 THEN 'Sun'
                WHEN 2 THEN 'Mon'
                WHEN 3 THEN 'Tue'
                WHEN 4 THEN 'Wed'
                WHEN 5 THEN 'Thu'
                WHEN 6 THEN 'Fri'
                WHEN 7 THEN 'Sat'
            END;
            
            
/*Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar).*/ 
/*Help determine which month of the year has the most sales and profit.*/

ALTER TABLE Amazonesales
ADD COLUMN Monthname VARCHAR(15);     /*Adding New Column Monthname*/

UPDATE Amazonesales 
SET monthname = CASE MONTH(Dates)
                WHEN 1 THEN 'Jan'
                WHEN 2 THEN 'Feb'
                WHEN 3 THEN 'Mar'
                WHEN 4 THEN 'Apr'
                WHEN 5 THEN 'May'
                WHEN 6 THEN 'Jun'
                WHEN 7 THEN 'Jul'
                WHEN 8 THEN 'Aug'
                WHEN 9 THEN 'Sep'
                WHEN 10 THEN 'Oct'
                WHEN 11 THEN 'Nov'
                WHEN 12 THEN 'Dec'
            END;
            
 /* Business Questions To Answer:*/
 
 /*1.What is the count of distinct cities in the dataset?*/
 
 select count(distinct city) as city_count from Amazonesales;
            
/*2.For each branch, what is the corresponding city?*/

select Branch, City from Amazonesales 
group by Branch, City;

/* 3.What is the count of distinct product lines in the dataset?*/

select count(distinct Product_line) as Distinct_product_line from amazonesales;

/*4.Which payment method occurs most frequently?*/

SELECT payment, COUNT(*) AS Freq FROM Amazonesales
GROUP BY payment
ORDER BY Freq DESC
LIMIT 1;

/*5. Which product line has the highest sales?*/

SELECT Product_line, SUM(Total) AS Total_sales FROM amazonesales
GROUP BY Product_line 
ORDER BY Total_sales DESC
LIMIT 1;

/*6.How much revenue is generated each month?*/

select YEAR(Dates) as Year, MONTH(Dates) as Month, SUM(Total) FROM Amazonesales 
group by YEAR(Dates), MONTH(Dates)
order by Year, Month;

/* 7.In which month did the cost of goods sold reach its peak?*/

select YEAR(Dates) as Year, MONTH(Dates) as Month, SUM(Cogs) FROM Amazonesales 
group by YEAR(Dates), MONTH(Dates)
order by SUM(Cogs) desc
limit 1;

/*8.Which product line generated the highest revenue?*/

select Product_line, sum(Total) from amazonesales
group by Product_line
order by sum(Total) desc
limit 1;

/*9.In which city was the highest revenue recorded?*/

select city, sum(Total) from Amazonesales 
group by city
order by sum(total) Desc
limit 1;

/*10.Which product line incurred the highest Value Added Tax?*/

select Product_line, sum(VAT) from Amazonesales
group by Product_line
order by sum(VAT)
LIMIT 1;

/*11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."*/

SELECT product_line,SUM(total) AS Total,AVG(SUM(total)) OVER() AS Avg_sales,
    CASE 
        WHEN SUM(total) > AVG(SUM(total)) OVER() THEN 'Good'
        ELSE 'Bad'
    END AS sales_quality
FROM Amazonesales
GROUP BY product_line;

/*12. Identify the branch that exceeded the average number of products sold.*/

SELECT Branch, SUM(quantity) AS Total_quantity FROM Amazonesales
GROUP BY branch
HAVING Total_quantity > (SELECT AVG(quantity) FROM Amazonesales);
        
/*13.Which product line is most frequently associated with each gender?*/

select Gender, Product_line, count(*) as Freq from Amazonesales
Group by Gender, Product_line
order by Gender, Freq desc;

/*14.Calculate the average rating for each product line.*/
select Product_line, Avg(Rating) as Avg_rating from amazonesales
group by Product_line;

/*15.Count the sales occurrences for each time of day on every weekday.*/

SELECT Dayname, time_of_day, COUNT(*) AS sales_occurrences FROM Amazonesales
WHERE Dayname NOT IN ('Sat', 'Sun')
GROUP BY Dayname, time_of_day
ORDER BY Dayname , time_of_day;

/*16.Identify the customer type contributing the highest revenue.*/

select Customer_type, sum(Total) as Revenue from amazonesales 
group by Customer_type
order by Revenue Desc 
limit 1;

/*17.Determine the city with the highest VAT percentage.*/
select City, AVG(VAT / total) * 100 AS Avg_Vat_Per from Amazonesales 
GROUP BY City
ORDER BY Avg_Vat_Per DESC
LIMIT 1;

/*18.Identify the customer type with the highest VAT payments*/

select Customer_type, SUM(VAT) AS Total_vat from Amazonesales 
group by Customer_type
order by Total_vat
limit 1;

/*19.What is the count of distinct customer types in the dataset?*/

select count(Distinct Customer_type) as No_of_Total_customer from Amazonesales;

/*20 What is the count of distinct payment methods in the dataset?*/

select count(Distinct Payment) as No_of_Payment from Amazonesales;

/*21.Which customer type occurs most frequently?*/

select Customer_type, count(*) as Frequency from Amazonesales
group by Customer_type
order by Frequency
limit 1;

/*22.Identify the customer type with the highest purchase frequency.*/

select Customer_type, COUNT(*) AS purchase_frequency from Amazonesales
GROUP BY customer_type
ORDER BY purchase_frequency DESC
LIMIT 1;

/*23. Determine the predominant gender among customers.*/
select Gender, count(*) As Gender_count from Amazonesales 
group by Gender
order by Gender_count
limit 1;

/*24.Examine the distribution of genders within each branch.*/

select Branch, Gender, count(*) as Gender_count from Amazonesales
group by Branch, Gender
order by Branch, Gender;

/*25.Identify the time of day when customers provide the most ratings*/

select time_of_day ,count(*) as Rating_Count from Amazonesales 
group by time_of_day
order by Rating_Count DESC
LIMIT 1;

/*26.Determine the time of day with the highest customer ratings for each branch.*/

SELECT Branch, time_of_day, AVG(rating) AS avg_rating FROM Amazonesales
group by Branch, time_of_day
order by Branch, avg_rating desc;

/*27.Identify the day of the week with the highest average ratings.*/

select Dayname, AVG(Rating) as Avg_rating from Amazonesales
group by Dayname
order by Avg_rating
limit 1; 

/*28.Determine the day of the week with the highest average ratings for each branch.*/

select Dayname, Branch, AVG(Rating) as Avg_rating from Amazonesales
group by Dayname, Branch 
order by Branch, Avg_rating ;


/*                    THE END                    */
