
-- Creating Database
CREATE DATABASE E_COMMERCE;

-- Select the Database
USE E_COMMERCE;


--Preview Customers Table
SELECT Top 10 * 
FROM OLIST_Customer;


--Preview Orders Table
SELECT Top 10 * 
FROM OLIST_Orders;


--Preview Ordered Items Table
SELECT Top 10 * 
FROM OLIST_Ordered_Items;


--Preview Products Table
SELECT Top 10 * 
FROM OLIST_Products;



--Preview Payments Table
SELECT Top 10 * 
FROM OLIST_Orders_Payment;


--Checking Rows in Ecah Table:
SELECT 
     count(*) As
     'Total Customers'
FROM 
    OLIST_Customer;

SELECT 
     count(*) As
     'Total Orders'
FROM 
    OLIST_Orders;

SELECT 
     count(*) As
     'Total Items Ordered'
FROM 
    OLIST_Ordered_Items;

SELECT 
    count(*) As
    'Total Products'
FROM 
    OLIST_Products;


SELECT 
     count(*) As
     'Number of Payments Made'
FROM
    OLIST_Orders_Payment;


-- Joining Orders and Customers Table together to understand the relationship:
Select
    o.order_id
    ,o.customer_id
    ,c.customer_city
    ,c.customer_state
    ,o.order_purchase_timestamp
From
    Olist_Orders as o
Join
    Olist_Customer as c
ON
   o.customer_id = c.customer_id;




--Adding Order Items Table in Customers and Orders Table
Select 
     o.order_id
     ,c.customer_city
     ,oi.product_id
     ,oi.price
From
    Olist_Orders as o
Join
    Olist_Customer as c
On
   o.customer_id = c.customer_id
Join
   Olist_Ordered_Items as oi
ON
   o.order_id = oi.order_id
 ;

 Select 
     Top 10 *
From
    Olist_Orders as o
Join
    Olist_Customer as c
On
   o.customer_id = c.customer_id
Join
   Olist_Ordered_Items as oi
ON
   o.order_id = oi.order_id
 ;

 --Final DataSet Preview
 Select 
     Top 1000
     o.order_id
     ,o.order_purchase_timestamp
     ,c.customer_city
     ,c.customer_state
     ,oi.product_id
     ,oi.price
     ,p.payment_value
     ,pr.product_category_name
From
    Olist_Orders as o
Join
    Olist_Customer as c
On 
   o.customer_id = c.customer_id
Join
   Olist_Ordered_Items as oi
On 
   o.order_id = oi.order_id
Join
   Olist_Orders_Payment as p
On
   o.order_id = p.order_id
Join
   Olist_Products as pr
On 
   oi.product_id = pr.product_id
;



--Combining all the tables into 1 final Table
SELECT 
    o.order_id
    ,o.customer_id
    ,c.customer_city
    ,c.customer_state
    ,o.order_purchase_timestamp
    ,o.order_status
    ,oi.product_id
    ,oi.price
    ,oi.freight_value
    ,p.payment_type
    ,p.payment_value
    ,pr.product_category_name
INTO 
    Final_dataset_org
FROM 
    Olist_Orders as  o
JOIN 
    Olist_Customer as c 
ON 
    o.customer_id = c.customer_id
JOIN 
    Olist_Ordered_Items as oi 
ON 
    o.order_id = oi.order_id
JOIN 
    Olist_Orders_Payment as p 
ON 
    o.order_id = p.order_id
JOIN 
    Olist_Products as pr 
ON 
    oi.product_id = pr.product_id
 ;



--Verifying  :
 Select
     Count(*) As Total
 From 
     Final_dataset_org;


--Copy of Original
Select *
Into 
   Cleaned_Dataset
From 
   Final_Dataset_org;



--DATA CLEANING

--Checking For Null Values:
Select 
     Count(*) 
     As Null_Payment
From 
    Cleaned_Dataset
Where 
    payment_value 
    Is Null;



--Checking For Duplicates
Select 
      order_id
      ,Count(*)
      As 'Dupliacte Orders'
From 
    Cleaned_Dataset
Group By
     order_id
Having
     Count(*) > 1;


Select 
      customer_id
      ,Count(*)
      As 'Dupliacte Customers'
From 
    Cleaned_Dataset
Group By
     customer_id
Having
     Count(*) > 1;



--These duplicates may exists due to joins

Select
     Distinct *
Into
    Cleaned_Data_distinct
From
    Cleaned_Dataset
;


--Fixing Date Format
Alter Table Cleaned_Data_distinct
Add order_date Date;

Update Cleaned_Data_distinct
SET order_date = Cast(order_purchase_timestamp
As Date)


--Dealing with Negatives
Delete From Cleaned_Data_distinct
Where payment_value <= 0;





--Handle Missing Category
Update Cleaned_Data_distinct
SET product_category_name = 'Unknown'
Where product_category_name Is Null;


--Analyzing the Data

--What is total revenue and total number of Orders?
Select
     Count(Distinct order_id)
     As Total_Orders
     ,Round(Sum(payment_value),2)
     As Total_Revenue
From
    Cleaned_Data_distinct;


--What is Monthly Sales Trend ?
Select
     Format(order_date, 'yyyy-MM')
     As 'Month'
     ,Round(Sum(Payment_value),2)
     As 'Revenue'
From
    Cleaned_Data_distinct
Group By
     Format(order_date, 'yyyy-MM')
Order By
    'Month';


--What are Top 10 Product Categories ?
Select 
    Top 10
    product_category_name
    ,Round(Sum(payment_value),2)
    As Revenue
From
    Cleaned_Data_distinct
Group By
    product_category_name
Order By
    Revenue Desc;
    

--What are Top States by Revenue ?
Select
    customer_state
    ,Round(Sum(payment_value),2)
    As 'Revenue'
From
    Cleaned_Data_distinct
Group By
    customer_state
Order By
    Revenue Desc;


--What are the most prefered payment methods ?
Select
     payment_type
     ,Count(*) As
     'Transaction'
     ,Round(Sum(payment_value),2)
     As Revenue
From
    Cleaned_Data_distinct
Group By
    payment_type
Order By
    Revenue Desc;


--What is customers purchasing power ?
Select
     Round(Sum(payment_value)
     / Count(Distinct order_id),2)
     As avg_order_value
From
    Cleaned_Data_distinct;


--Who are the Top 5 Customers ?
Select
     Top 5
     customer_id
     ,Round(Sum(payment_value),2)
     As Total_spent
From
    Cleaned_Data_distinct
Group By
    customer_id
Order By
    total_spent Desc;


--Which days have the highest order volume?
Select
     Datename(Weekday , order_date)
     As 'day'
     ,Count(Distinct order_id) As
     'Orders'
From
    Cleaned_Data_distinct
Group By
    Datename(Weekday , order_date)
;

Select 
     order_id As Order_ID
     ,customer_id As Customer_ID
     ,customer_city As City
     ,customer_state As 'State'
     ,order_purchase_timestamp As Purchase_Timestamp
     ,order_status As Order_Status
     ,product_id As Product_ID
     ,price As Price
     ,freight_value As Freight
     ,payment_type As Payment_Type
     ,payment_value As Payment_Value
     ,product_category_name As Category
     ,order_date As Order_Date
From 
    Cleaned_Data_distinct;