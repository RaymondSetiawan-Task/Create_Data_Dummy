DROP TABLE Transaction_dtl;
DROP TABLE Transaction_hdr;
DROP TABLE product;
DROP TABLE qty_product;
DROP TABLE category_product;
DROP TABLE Salesman;
DROP TABLE Customer;

CREATE TABLE Qty_product (
	QtyID varchar(50) PRIMARY KEY,
	Qty_name varchar(50) NOT NULL,
	Qty_value int NOT NULL
);

CREATE TABLE Category_product (
	CategoryID varchar(50) PRIMARY KEY,
    Category_type varchar(50) NOT NULL
);

CREATE TABLE Product (
	ProductID varchar(50) PRIMARY KEY,
    Product_name varchar(100) NOT NULL,
	CategoryID varchar(50) NOT NULL,
	Size varchar(100) NOT NULL,
	QtyID varchar(50) NOT NULL,
    Stock int NOT NULL,
	Price_product int NOT NULL,
	FOREIGN KEY (CategoryID) REFERENCES Category_product(CategoryID),
	FOREIGN KEY (QtyID) REFERENCES Qty_product(QtyID)
);

CREATE TABLE Salesman (
	SalesID varchar(50) PRIMARY KEY,
	Sales_name varchar(255) NOT NULL,
	Sales_phone varchar (12) NOT NULL,
	Sales_address varchar(255)
);

CREATE TABLE Customer (
	CustomerID varchar(50) PRIMARY KEY,
	Customer_name varchar(255) NOT NULL,
	Customer_phone varchar (12) NOT NULL,
	Customer_address varchar(255) NOT NULL
);

CREATE TABLE Transaction_hdr (
	Transcation_hdrID varchar(50) PRIMARY KEY,
    TransactionDate date NOT NULL,
    SalesID varchar(50) NOT NULL,
	CustomerID varchar(50),
	Total_price int NOT NULL,
	FOREIGN KEY (SalesID) REFERENCES Salesman(SalesID),
	FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE Transaction_dtl (
    Transaction_dtlID varchar(50) PRIMARY KEY,
    Transcation_hdrID varchar(50) NOT NULL,
    ProductID varchar(50) NOT NULL,
    Product_name varchar(100) NOT NULL, 
	CategoryID varchar(50) NOT NULL,
	QtyID varchar(50) NOT NULL,
	Qty_value int NOT NULL,
	Qty int NOT NULL,
	Price_product int NOT NULL,
    Price int NOT NULL,
    FOREIGN KEY (Transcation_hdrID) REFERENCES Transaction_hdr(Transcation_hdrID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
