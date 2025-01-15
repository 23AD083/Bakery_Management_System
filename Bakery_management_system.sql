CREATE DATABASE IF NOT EXISTS bake;
USE bake;
-- Customer Table
CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    contact_info VARCHAR(50) NOT NULL
);

-- BakeryItem Table (Parent Table for Different Item Types)
CREATE TABLE BakeryItem (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(50) NOT NULL,
    item_type VARCHAR(20) NOT NULL,  -- Cake, Pastry, Bread
    price DECIMAL(10, 2) NOT NULL
);

-- Order Table (Links to Customer Table)
CREATE TABLE `Order` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Placed',
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- OrderItems Table (Links Orders and BakeryItems with Quantity)
CREATE TABLE OrderItems (
    order_id INT,
    item_id INT,
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES BakeryItem(item_id) ON DELETE CASCADE
);

-- Pickup Table (Links Order to Pickup Details)
CREATE TABLE Pickup (
    pickup_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    pickup_time TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE
);

-- OrderLog Table for Logging Order Status Changes
CREATE TABLE OrderLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) ON DELETE CASCADE
);

-- Stored Procedure for Processing an Order
DELIMITER //
CREATE PROCEDURE processOrder(IN orderId INT)
BEGIN
    UPDATE `Order` SET status = 'Processed' WHERE order_id = orderId;
END //
DELIMITER ;

-- Stored Procedure for Cancelling an Order
DELIMITER //
CREATE PROCEDURE cancelOrder(IN orderId INT)
BEGIN
    UPDATE `Order` SET status = 'Cancelled' WHERE order_id = orderId;
END //
DELIMITER ;

-- Trigger to Log Changes in Order Status
DELIMITER //
CREATE TRIGGER logOrderStatusChange AFTER UPDATE ON `Order`
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO OrderLog (order_id, old_status, new_status, changed_at)
        VALUES (OLD.order_id, OLD.status, NEW.status, NOW());
    END IF;
END //
DELIMITER ;

-- Indexes for Performance
CREATE INDEX idx_order_id ON `Order`(order_id);
CREATE INDEX idx_customer_id ON Customer(customer_id);
