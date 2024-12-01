DROP DATABASE Olist_warehouse;

CREATE DATABASE Olist_warehouse;

USE Olist_warehouse;

-- revise add date data recived to time stamp etl jobs

BEGIN TRANSACTION
USE Olist_warehouse;

-- Drop tables if they exist for re-creation
DROP TABLE IF EXISTS Fact_OrderItems;
DROP TABLE IF EXISTS Dim_Customers;
DROP TABLE IF EXISTS Dim_Sellers;
DROP TABLE IF EXISTS Dim_Products;
DROP TABLE IF EXISTS Dim_Reviews;
DROP TABLE IF EXISTS Dim_Payments;
DROP TABLE IF EXISTS Dim_Orders;
DROP TABLE IF EXISTS Dim_Geolocation;
DROP TABLE IF EXISTS Dim_Date;
DROP TABLE IF EXISTS Dim_Time;
DROP TABLE IF EXISTS Junk_OrderItems;


-- 1. Create Dimension Tables

CREATE TABLE Dim_Geolocation (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incrementing surrogate key for warehouse
    olist_db_id int NOT NULL,  -- Original ID from operational database
	geolocation_zip_code_prefix NVARCHAR(10) NOT NULL, -- Original ID from the dataset
    geolocation_lat DECIMAL(18, 15) NOT NULL,  
    geolocation_lng DECIMAL(18, 15) NOT NULL,  
    geolocation_city NVARCHAR(100) NOT NULL,  
    geolocation_state CHAR(2) NOT NULL,  
    etl_date DATE NOT NULL
);

CREATE TABLE Dim_Customers (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incrementing surrogate key for warehouse
    olist_db_id INT NOT NULL,  -- Original ID from operational database
	customer_id NVARCHAR(50) NOT NULL, -- Original ID from the dataset
    customer_unique_id NVARCHAR(50) NOT NULL,  
    customer_zip_code_prefix NVARCHAR(10) NOT NULL,  
    customer_city NVARCHAR(100) NOT NULL,  
    customer_state CHAR(2) NOT NULL,
    etl_date DATE NOT NULL
    --CONSTRAINT UC_Customers UNIQUE (olist_db_id)
);

CREATE TABLE Dim_Orders (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incrementing surrogate key for warehouse
    olist_db_id int NOT NULL,  -- Original ID from operational database
	order_id NVARCHAR(50) NOT NULL, -- Original ID from the dataset
    customer_id NVARCHAR(50) NOT NULL,  
    order_status NVARCHAR(20) NOT NULL,  
    order_purchase_timestamp DATETIME NOT NULL,  
    order_approved_at DATETIME NULL,  
    order_delivered_carrier_date DATETIME NULL,  
    order_delivered_customer_date DATETIME NULL,  
    order_estimated_delivery_date DATETIME NOT NULL,  
    etl_date DATE NOT NULL
);

CREATE TABLE Dim_Products (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incrementing surrogate key for warehouse
    olist_db_id int NOT NULL,  -- Original ID from operational database
	product_id NVARCHAR(50) NOT NULL, -- Original ID from the dataset
    product_category_name NVARCHAR(50) NULL,  
    product_name_length INT NULL,  
    product_description_length INT NULL,  
    product_photos_qty INT NULL,  
    product_weight_g INT NULL,  
    product_length_cm INT NULL,  
    product_height_cm INT NULL,  
    product_width_cm INT NULL,  
    etl_date DATE NOT NULL
);

CREATE TABLE Dim_Sellers (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incrementing surrogate key for warehouse
    olist_db_id int NOT NULL,  -- Original ID from operational database
	seller_id NVARCHAR(50) NOT NULL, -- Original ID from the dataset
    seller_zip_code_prefix NVARCHAR(10) NOT NULL,  
    seller_city NVARCHAR(100) NOT NULL,  
    seller_state CHAR(2) NOT NULL,  
    etl_date DATE NOT NULL
);

-- 2. Create Junk Dimension for Operational Keys

CREATE TABLE Junk_OrderItems (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incrementing surrogate key for warehouse
	olist_db_id int NOT NULL,  -- Original ID from operational database
	order_id NVARCHAR(50) NOT NULL,  
    order_item_id INT NOT NULL, 
    product_id NVARCHAR(50) NOT NULL,  
    seller_id NVARCHAR(50) NOT NULL,  
    etl_date DATE NOT NULL
);


-- 3. Create Snowflaked Dimensions

CREATE TABLE Dim_Reviews (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incrementing surrogate key for warehouse
	dim_order_warehouse_id INT NOT NULL, -- Surrogate key from Orders Dimension
	olist_db_id int NOT NULL, -- reviews surrogate key from operational database source
    review_id NVARCHAR(50) NOT NULL, -- review id from dataset source
	order_id NVARCHAR(50) NOT NULL,
    review_score INT NOT NULL,  
    review_comment_title NVARCHAR(255) NULL,  
    review_comment_message NVARCHAR(MAX) NULL,  
    review_creation_date DATETIME NOT NULL,  
    review_answer_timestamp DATETIME NULL, 
    etl_date DATE NOT NULL,
    FOREIGN KEY (dim_order_warehouse_id) REFERENCES Dim_Orders(warehouse_id)
);


CREATE TABLE Dim_Payments (
    warehouse_id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-incrementing surrogate key for warehouse
	dim_order_warehouse_id INT NOT NULL,  -- Surrogate key from Orders Dimension
	olist_db_id INT NOT NULL, -- payments surrogate key form operational database source
	order_id NVARCHAR(50) NOT NULL,
    payment_sequential INT NOT NULL,  -- payment id from dataset source
    payment_type NVARCHAR(20) NOT NULL,  
    payment_installments INT NOT NULL,  
    payment_value DECIMAL(10, 2) NOT NULL,  
    etl_date DATE NOT NULL,
    FOREIGN KEY (dim_order_warehouse_id) REFERENCES Dim_Orders(warehouse_id)
);

-- 4. Create Date and Time Dimensions
CREATE TABLE Dim_Date (
    date_key INT PRIMARY KEY,  
    date DATE NOT NULL,  
    year INT NOT NULL,  
    month INT NOT NULL,  
    day INT NOT NULL,  
    weekday INT NOT NULL
);


GO
-- 1. Drop the table if it already exists (optional)
IF OBJECT_ID('dbo.Dim_Date', 'U') IS NOT NULL
DROP TABLE dbo.Dim_Date;

-- 2. Create the Dim_Date table
CREATE TABLE dbo.Dim_Date (
    date_key INT PRIMARY KEY,  
    date DATE NOT NULL,  
    year INT NOT NULL,  
    month INT NOT NULL,  
    day INT NOT NULL,  
    weekday INT NOT NULL
);
GO

-- 3. Create the stored procedure to populate the Dim_Date table
CREATE OR ALTER PROCEDURE dbo.GenerateDimDateTable
(
    @start_date DATE,
    @end_date DATE
)
AS
BEGIN
    DECLARE @current_date DATE = @start_date;
    
    WHILE @current_date <= @end_date
    BEGIN
        INSERT INTO dbo.Dim_Date
        (
            date_key,
            date,
            year,
            month,
            day,
            weekday
        )
        VALUES
        (
            CONVERT(INT, CONVERT(VARCHAR(8), @current_date, 112)), -- YYYYMMDD format as date_key
            @current_date,
            YEAR(@current_date),
            MONTH(@current_date),
            DAY(@current_date),
            DATEPART(WEEKDAY, @current_date) -- returns the day of the week (1=Sunday, 2=Monday, etc.)
        );
        
        SET @current_date = DATEADD(DAY, 1, @current_date);
    END;
END;
GO


-- CREATE TABLE Dim_Time (
--    time_key INT PRIMARY KEY,  
--    hour INT NOT NULL,  
--   minute INT NOT NULL,  
--    second INT NOT NULL
-- );


-- 5. Create Fact Table: Fact_OrderItems
CREATE TABLE Fact_OrderItems (
	warehouse_fact_id INT IDENTITY(1,1) PRIMARY KEY,
    order_item_id INT NOT NULL,  -- Auto-incrementing surrogate key for warehouse
    order_id INT NOT NULL,  -- Surrogate key from Orders Dimension
	order_purchase_date INT NOT NULL,
    customer_id INT NOT NULL,  -- Surrogate key from Customers Dimension
    customer_location_id INT NOT NULL,  -- Surrogate key from Geolocation (for customer)
    seller_id INT NOT NULL,  -- Surrogate key from Sellers Dimension
    seller_location_id INT NOT NULL,  -- Surrogate key from Geolocation (for seller)
    product_id INT NOT NULL,  -- Surrogate key from Products Dimension
    shipping_limit_date DATE NOT NULL,  
    price DECIMAL(10, 2) NOT NULL,  
    freight_value DECIMAL(10, 2) NOT NULL,  
    etl_date DATE NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Dim_Orders(warehouse_id),
    FOREIGN KEY (customer_id) REFERENCES Dim_Customers(warehouse_id),
    FOREIGN KEY (customer_location_id) REFERENCES Dim_Geolocation(warehouse_id),
    FOREIGN KEY (seller_id) REFERENCES Dim_Sellers(warehouse_id),
    FOREIGN KEY (seller_location_id) REFERENCES Dim_Geolocation(warehouse_id),
    FOREIGN KEY (product_id) REFERENCES Dim_Products(warehouse_id),
	FOREIGN KEY (order_item_id) REFERENCES Junk_OrderItems(warehouse_id),
	FOREIGN KEY (order_purchase_date) REFERENCES Dim_date(date_key)
);

COMMIT TRANSACTION