CREATE DATABASE food_delivery;
USE food_delivery;

-- Table for restaurants
CREATE TABLE restaurants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL
);

-- Table for menu items
CREATE TABLE menu (
    id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    cuisine VARCHAR(100) NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);

-- Table for users (to store customer details)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(15) NOT NULL
);

-- Table for orders
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    restaurant_id INT,
    menu_item_id INT,
    price DECIMAL(10,2) NOT NULL,
    status ENUM('Pending', 'Completed', 'Cancelled') DEFAULT 'Pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
    FOREIGN KEY (menu_item_id) REFERENCES menu(id)
);

-- Table for payments
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    user_id INT,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'UPI', 'Cash on Delivery') NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Completed',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Table for customer reviews
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    restaurant_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

-- Insert sample restaurants
INSERT INTO restaurants (name, location) VALUES 
('Dominos', 'Pune'), 
('Burger King', 'Mumbai'), 
('Subway', 'Delhi');

-- Insert sample menu items
INSERT INTO menu (restaurant_id, name, price, cuisine) VALUES 
(1, 'Margherita Pizza', 299.00, 'Italian'),
(1, 'Pasta Alfredo', 349.00, 'Italian'),
(2, 'Butter Chicken', 399.00, 'Indian'),
(2, 'Paneer Tikka', 299.00, 'Indian'),
(3, 'Sushi Roll', 499.00, 'Japanese'),
(3, 'Ramen Bowl', 399.00, 'Japanese');

-- Insert sample users
INSERT INTO users (name, email, phone) VALUES 
('Anushka Gunjal', 'anushka@example.com', '9876543210');

