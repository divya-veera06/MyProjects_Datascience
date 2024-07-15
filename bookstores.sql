CREATE DATABASE StoreBooks1;
use StoreBooks1;
CREATE TABLE books (
    ISBN VARCHAR(20) PRIMARY KEY,
    Title VARCHAR(255),
    AuthorID VARCHAR(36),
    PublisherID VARCHAR(36),
    Price DECIMAL(5, 2),
    Genre VARCHAR(50),
    Stock INT
);
CREATE TABLE customers (
    CustomerID CHAR(36) PRIMARY KEY,
    Name VARCHAR(255),
    Email VARCHAR(255),
    Address TEXT
);
CREATE TABLE orders (
    OrderID CHAR(36) PRIMARY KEY,
    CustomerID CHAR(36),
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID)
);
CREATE TABLE orderDetails (
    OrderDetailID INT NOT NULL AUTO_INCREMENT,
    OrderID CHAR(36),
    ISBN VARCHAR(20),
    Quantity INT,
    Price DECIMAL(5, 2),
    PRIMARY KEY (OrderDetailID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ISBN) REFERENCES Books(ISBN)
);
-- Retrieve information about books, authors, publishers, customers, and orders.
select*from books;
SET FOREIGN_KEY_CHECKS = 0;
truncate table books;
select*from customers;
select*from orders;
select * from orderdetails;

-- Find the total sales for each book.
SELECT b.ISBN, b.Title, SUM(o.TotalAmount) AS TotalSales
FROM Books b
LEFT JOIN OrderDetails od ON b.ISBN = od.ISBN
LEFT JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY b.ISBN, b.Title
ORDER BY TotalSales DESC;

-- List the top 5 best-selling books.
SELECT b.ISBN, b.Title, SUM(od.Quantity) AS TotalQuantitySold
FROM Books b
LEFT JOIN OrderDetails od ON b.ISBN = od.ISBN
GROUP BY b.ISBN, b.Title
ORDER BY TotalQuantitySold DESC
LIMIT 5;

-- Retrieve customer information who placed orders within the last month.
SELECT DISTINCT c.CustomerID, c.Name, c.Email, c.Address
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);

-- Calculate the total revenue generated by a specific publisher.
SELECT SUM(od.Quantity * od.Price) AS TotalRevenue
FROM OrderDetails od
JOIN Books b ON od.ISBN = b.ISBN
WHERE b.PublisherID = 'publisher_055';

--  Find Customers Who Have Not Placed Orders
SELECT c.CustomerID, c.Name, c.Email
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

-- Retrieve Books Without Orders
SELECT b.ISBN, b.Title
FROM Books b
LEFT JOIN OrderDetails od ON b.ISBN = od.ISBN
WHERE od.ISBN IS NULL;

-- Updating Book Prices

UPDATE Books
SET Price = 12.99  
WHERE ISBN = '978-3-16-148410-0'; 

-- Updating Stock Levels

UPDATE Books
SET Stock = Stock - 1  
WHERE ISBN = '978-3-16-148410-0';  


-- Deleting Orders
DELETE FROM Orders
WHERE OrderID = 'order_001'; 


-- Placing an Order
DELIMITER //

CREATE PROCEDURE PlaceOrder (
    IN p_CustomerID VARCHAR(36),
    IN p_OrderDate DATE,
    IN p_OrderDetails JSON
)
BEGIN
    -- Declare variables
    DECLARE order_id VARCHAR(36);
    DECLARE book_isbn VARCHAR(20);
    DECLARE book_quantity INT;
    DECLARE book_price DECIMAL(5, 2);

    -- Start transaction
    START TRANSACTION;

    -- Insert into Orders table
    INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount)
    VALUES (UUID(), p_CustomerID, p_OrderDate, 0);  -- TotalAmount initially set to 0

    -- Get the last inserted OrderID
    SELECT LAST_INSERT_ID() INTO order_id;

    -- Loop through each item in p_OrderDetails JSON array
    WHILE JSON_CONTAINS_PATH(p_OrderDetails, 'one', '$[*]') > 0 DO
        -- Extract book details
        SET book_isbn = JSON_UNQUOTE(JSON_EXTRACT(p_OrderDetails, CONCAT('$[', JSON_SEARCH(p_OrderDetails, 'one', 'book_isbn', NULL, '$[*]'), ']')));
        SET book_quantity = JSON_UNQUOTE(JSON_EXTRACT(p_OrderDetails, CONCAT('$[', JSON_SEARCH(p_OrderDetails, 'one', 'book_quantity', NULL, '$[*]'), ']')));
        SET book_price = (SELECT Price FROM Books WHERE ISBN = book_isbn);

        -- Insert into OrderDetails table
        INSERT INTO OrderDetails (OrderDetailID, OrderID, ISBN, Quantity, Price)
        VALUES (UUID(), order_id, book_isbn, book_quantity, book_price);

        -- Update stock in Books table
        UPDATE Books
        SET Stock = Stock - book_quantity
        WHERE ISBN = book_isbn;

        -- Calculate total amount for the order
        UPDATE Orders
        SET TotalAmount = (
            SELECT SUM(od.Quantity * od.Price)
            FROM OrderDetails od
            WHERE od.OrderID = order_id
        )
        WHERE OrderID = order_id;

        -- Remove processed item from JSON array
        SET p_OrderDetails = JSON_REMOVE(p_OrderDetails, CONCAT('$[', JSON_SEARCH(p_OrderDetails, 'one', 'book_isbn', NULL, '$[*]'), ']'));
    END WHILE;

    -- Commit transaction
    COMMIT;
END //

DELIMITER ;




