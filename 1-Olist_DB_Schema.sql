-- Drop tables if they exist for re-creation (optional, uncomment to use)
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS ProductTranslations;
DROP TABLE IF EXISTS Sellers;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Geolocation;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Reviews;


-- Table for Geolocation
CREATE TABLE Geolocation (
    id INT IDENTITY(1,1) PRIMARY KEY,                       		
    geolocation_zip_code_prefix NVARCHAR(10) NOT NULL UNIQUE,     	
    geolocation_lat DECIMAL(18, 15) NOT NULL,               	
    geolocation_lng DECIMAL(18, 15) NOT NULL,               		
    geolocation_city NVARCHAR(100) NOT NULL,                		
    geolocation_state CHAR(2) NOT NULL  )                    		

-- Table for Customers
CREATE TABLE Customers (
    id INT IDENTITY(1,1) PRIMARY KEY,                       
    customer_id NVARCHAR(50) NOT NULL,                     
    customer_unique_id NVARCHAR(50) NOT NULL,              
    customer_zip_code_prefix NVARCHAR(10) NOT NULL,         
    customer_city NVARCHAR(100) NOT NULL,                 
    customer_state CHAR(2) NOT NULL,                        
    CONSTRAINT UC_Customers UNIQUE (customer_id)          
);

-- Add foreign key constraint between Customers and Geolocation tables
ALTER TABLE Customers
ADD CONSTRAINT FK_Customers_Geolocation
FOREIGN KEY (customer_zip_code_prefix) REFERENCES Geolocation(geolocation_zip_code_prefix);

-- Create the Orders table
CREATE TABLE Orders (
    id INT IDENTITY(1,1) PRIMARY KEY,                        
    order_id NVARCHAR(50) NOT NULL UNIQUE,                  
    customer_id NVARCHAR(50) NOT NULL,                     
    order_status NVARCHAR(20) NOT NULL,                     
    order_purchase_timestamp DATETIME NOT NULL,            
    order_approved_at DATETIME NULL,                         
    order_delivered_carrier_date DATETIME NULL,             
    order_delivered_customer_date DATETIME NULL,            
    order_estimated_delivery_date DATETIME NOT NULL,      
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) 
);

-- Create the Payments table
CREATE TABLE Payments (
    id INT IDENTITY(1,1) PRIMARY KEY,                       
    order_id NVARCHAR(50) NOT NULL,                       
    payment_sequential INT NOT NULL,                       
    payment_type NVARCHAR(20) NOT NULL,                  
    payment_installments INT NOT NULL,                       
    payment_value DECIMAL(10, 2) NOT NULL,                  
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id) 
);

-- Create the Reviews table
CREATE TABLE Reviews (
    id INT IDENTITY(1,1) PRIMARY KEY,                       
    review_id NVARCHAR(50) NOT NULL,                        
    order_id NVARCHAR(50) NOT NULL,                         
    review_score INT NOT NULL,                             
    review_comment_title NVARCHAR(255) NULL,               
    review_comment_message NVARCHAR(MAX) NULL,             
    review_creation_date DATETIME NOT NULL,                
    review_answer_timestamp DATETIME NULL,                  
    CONSTRAINT FK_Reviews_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id) 
);

-- Create the Products table
CREATE TABLE Products (
    id INT IDENTITY(1,1) PRIMARY KEY,                      
    product_id NVARCHAR(50) NOT NULL UNIQUE,               
    product_category_name NVARCHAR(50) NULL,           
    product_name_length INT  NULL,                       
    product_description_length INT  NULL,               
    product_photos_qty INT  NULL,                        
    product_weight_g INT NULL,                          
    product_length_cm INT NULL,                        
    product_height_cm INT NULL,                         
    product_width_cm INT NULL,                          
);

-- Create the Sellers table
CREATE TABLE Sellers (
    id INT IDENTITY(1,1) PRIMARY KEY,                      
    seller_id NVARCHAR(50) NOT NULL UNIQUE,               
    seller_zip_code_prefix NVARCHAR(10) NOT NULL,          
    seller_city NVARCHAR(100) NOT NULL,                    
    seller_state CHAR(2) NOT NULL,                        
    CONSTRAINT FK_Sellers_Geolocation FOREIGN KEY (seller_zip_code_prefix) REFERENCES Geolocation(geolocation_zip_code_prefix) 
);

-- Create the OrderItems table
CREATE TABLE OrderItems (
    id INT IDENTITY(1,1) PRIMARY KEY,                      
    order_id NVARCHAR(50) NOT NULL,                        
    order_item_id INT NOT NULL,                           
    product_id NVARCHAR(50) NOT NULL,                      
    seller_id NVARCHAR(50) NOT NULL,                       
    shipping_limit_date DATETIME NOT NULL,                
    price DECIMAL(10, 2) NOT NULL,                         
    freight_value DECIMAL(10, 2) NOT NULL,                
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id), 
	CONSTRAINT FK_Products_OrderItems FOREIGN KEY (product_id) REFERENCES Products(product_id), 
	CONSTRAINT FK_Sellers_OrderItems FOREIGN KEY (seller_id) REFERENCES Sellers(seller_id) 
);
