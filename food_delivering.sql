create database KHAYALI_PULAW;
USE khayali_pulaw;


-- Table1: Users
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    address TEXT NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table2: Restaurants
CREATE TABLE Restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    rating DECIMAL(2,1) DEFAULT 0.0,
    cuisine_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table3: Menu
CREATE TABLE Menu (
    menu_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    availability BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id) ON DELETE CASCADE
);


    
#Table4: Orders
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    restaurant_id INT,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('Pending', 'Processing', 'Out for Delivery', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurants(restaurant_id) ON DELETE CASCADE
);

-- Table5: Order Details
CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    menu_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id) ON DELETE CASCADE
);

-- Table6: Delivery Partners
CREATE TABLE DeliveryPartners (
    delivery_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    vehicle_details VARCHAR(100),
    status ENUM('Available', 'Busy') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table7: Payments
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    user_id INT,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Credit Card', 'Debit Card', 'UPI', 'Cash on Delivery') NOT NULL,
    status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- Table8: Delivery Assignments
CREATE TABLE DeliveryAssignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    delivery_id INT,
    status ENUM('Assigned', 'Picked Up', 'Delivered') DEFAULT 'Assigned',
    assigned_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (delivery_id) REFERENCES DeliveryPartners(delivery_id) ON DELETE CASCADE
);

#----------------------INSERT_STATEMENTS----------------------------

INSERT INTO users ( name,email,phone,address,password) VALUES 
     ( "john ", 'john@gmail.com' , 1234567890 , 'larry park street2','john@123' );
     
INSERT INTO users ( name,email,phone,address,password) VALUES 
	 ( "ruby ", 'ruby@gmail.com' , 5656667890 , 'golden house street5','ruby@123' ),
      ( "harry ", 'harry@gmail.com' , 1234434320 , 'royal bay street7','harry@123' ),
       ( "jenny ", 'jenny@gmail.com' , 1234878790 , 'halfway home street8','jenny@123' ),
        ( "manny ", 'manny@gmail.com' , 1286868890 , 'larry park street2','manny@123' );
        
insert into restaurants (name,address,phone,rating,cuisine_type) values 
   ( 'bistro','malwan kullu 412321',6565656565,4.2,'kokani'),
   ( 'taj','mumbai maharashtra 560321',6888856565,4.9,'wish tumchi dish aamchi'),
   ( 'romania','hulewadi piune 411321',1111656565,4.5,'puneri'),
   ( 'soma','karjat satara 312321',6565687654,4.2,'south indian');
INSERT INTO menu (restaurant_id, item_name, price, category, availability) VALUES
    (1, 'Prawn Curry', 250.00, 'Seafood', TRUE),
    (1, 'Fish Thali', 350.00, 'Thali', TRUE),
    (2, 'Butter Chicken', 400.00, 'Non-Veg', TRUE),
    (2, 'Paneer Tikka', 300.00, 'Veg', TRUE),
    (3, 'Misal Pav', 120.00, 'Breakfast', TRUE),
    (3, 'Puran Poli', 150.00, 'Dessert', TRUE),
    (4, 'Dosa', 100.00, 'South Indian', TRUE),
    (4, 'Idli Sambar', 80.00, 'South Indian', TRUE);
-- Insert into Orders
INSERT INTO Orders (user_id, restaurant_id, total_amount, status) VALUES
    (1, 1, 600.00, 'Pending'),
    (2, 2, 700.00, 'Processing'),
    (3, 3, 250.00, 'Delivered'),
    (4, 4, 380.00, 'Out for Delivery'),
    (5, 1, 450.00, 'Cancelled');

-- Insert into OrderDetails
INSERT INTO OrderDetails (order_id, menu_id, quantity, price) VALUES
    (1, 1, 2, 500.00),
    (1, 2, 1, 100.00),
    (2, 3, 1, 400.00),
    (2, 4, 1, 300.00),
    (3, 5, 2, 240.00),
    (3, 6, 1, 150.00),
    (4, 7, 2, 200.00),
    (4, 8, 2, 180.00),
    (5, 1, 1, 250.00),
    (5, 4, 1, 200.00);

-- Insert into DeliveryPartners
INSERT INTO DeliveryPartners (name, phone, vehicle_details, status) VALUES
    ('Ravi Kumar', '9876543210', 'Bike - MH12AB1234', 'Available'),
    ('Ankit Sharma', '9876504321', 'Scooter - MH14XY5678', 'Busy'),
    ('Priya Singh', '9988776655', 'Bike - DL05PQ6789', 'Available'),
    ('Karan Patel', '9765432109', 'Scooter - GJ01RT4321', 'Busy');

-- Insert into Payments
INSERT INTO Payments (order_id, user_id, amount, payment_method, status) VALUES
    (1, 1, 600.00, 'Credit Card', 'Completed'),
    (2, 2, 700.00, 'UPI', 'Completed'),
    (3, 3, 250.00, 'Debit Card', 'Completed'),
    (4, 4, 380.00, 'Cash on Delivery', 'Pending'),
    (5, 5, 450.00, 'UPI', 'Failed');

-- Insert into DeliveryAssignments
INSERT INTO DeliveryAssignments (order_id, delivery_id, status) VALUES
    (1, 1, 'Assigned'),
    (2, 2, 'Picked Up'),
    (3, 3, 'Delivered'),
    (4, 4, 'Assigned');

insert into restaurants (name,address,phone,rating,cuisine_type) values 
   ( 'Garva','sinhagad Road',6565656569,3.8,'maharashtran'),
   ( 'TeAmo','Pune',6888856568,4.9,'Made with Love'),
   ( 'one eight cuisine','kondawa',1111656562,4.5,'Japanese');
   
   -- Insert menu items for 'Garva' (Maharashtrian Cuisine)
INSERT INTO Menu (restaurant_id, item_name, price, category, availability) VALUES 
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'Garva'), 'Puran Poli', 120.00, 'Dessert', TRUE),
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'Garva'), 'Misal Pav', 90.00, 'Breakfast', TRUE),
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'Garva'), 'Bharli Vangi', 150.00, 'Main Course', TRUE),
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'Garva'), 'Solkadhi', 50.00, 'Beverage', TRUE);

-- Insert menu items for 'TeAmo' (Made with Love Cuisine)
INSERT INTO Menu (restaurant_id, item_name, price, category, availability) VALUES 
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'TeAmo'), 'Chocolate Waffles', 180.00, 'Dessert', TRUE),
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'TeAmo'), 'Strawberry Smoothie', 150.00, 'Beverage', TRUE),
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'TeAmo'), 'Love Special Pasta', 200.00, 'Main Course', TRUE),
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'TeAmo'), 'Heart-Shaped Pizza', 300.00, 'Main Course', TRUE);

-- Insert menu items for 'One Eight Cuisine' (Japanese Cuisine)
INSERT INTO Menu (restaurant_id, item_name, price, category, availability) VALUES 
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'one eight cuisine'), 'Sushi Platter', 450.00, 'Main Course', TRUE),
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'one eight cuisine'), 'Ramen Bowl', 350.00, 'Main Course', TRUE),
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'one eight cuisine'), 'Miso Soup', 120.00, 'Starter', TRUE),
    ( (SELECT restaurant_id FROM Restaurants WHERE name = 'one eight cuisine'), 'Mochi Ice Cream', 180.00, 'Dessert', TRUE);

