select user();

select database();

show databases;

use mysql;

SELECT user, host, account_locked from mysql.user;

show tables;

describe mysql.user;


-- Create a nw database
create database multi_vendor_saas_marketplace;

-- Drop database
Drop database multi_vendor_saas_marketplace;

-- Use the new database
use multi_vendor_saas_marketplace;

-- Create a new user (Owner) for this db
create user 'multi_vendor_marketplace_admin'@'localhost' identified by 'pass1234';

-- Grant all previleges to the newly created user
grant all privileges on multi_vendor_saas_marketplace.* to 'multi_vendor_marketplace_admin'@'localhost';

-- View privileges of a specific user
SHOW GRANTS FOR 'multi_vendor_marketplace_admin'@'localhost';


-- *** Create Tables ***

-- ** user_type table
create table if not exists user_type (
	user_type_id INT not null auto_increment,
	user_type ENUM ('vendor', 'customer') not null,
	primary key (user_type_id),
	constraint unique_user_type unique(user_type)
);


-- ** user table
create table if not exists user (
	user_id INT not null auto_increment,
	user_fullname VARCHAR (150) not null,
	email VARCHAR (150) unique not null,
	phone VARCHAR (15) null,
	account_status BOOLEAN not null,
	registration_date DATE not null,
	user_type_id INT not null,
	primary key (user_id),
	constraint fk_user_type
		foreign key (user_type_id)
		references user_type (user_type_id)
		on delete restrict
		on update cascade
);


-- **Address table
create table if not exists address (
	address_id INT not null auto_increment,
	house_no VARCHAR (50) null,
	street_name VARCHAR (100) null,
	thana VARCHAR (50) null,
	city VARCHAR (50) null,
	district VARCHAR (50) null,
	primary key (address_id)
);


-- **user_address table 
-- Note: Conjunction between user & address tables, since a user might have multiple addresses, like home & workplace address for having the option of different delivery location
create table if not exists user_address (
	user_address_id INT not null auto_increment,
	user_id INT not null,
	address_id INT not null,
	address_type ENUM ('home', 'office') NOT null,
	primary key (user_address_id),
	constraint fk_user_user_address
		foreign key (user_id)
		references user (user_id)
		on delete cascade
		on update cascade,
	constraint fk_address_user_address 
		foreign key (address_id)
		references address (address_id)
		on delete cascade
		on update cascade
);


-- **subscription_plan table
create table if not exists subscription_plan (
	plan_id INT not null auto_increment,
	plan_name VARCHAR (150) not null,
	monthly_fee DECIMAL (9,2) not null,
	product_listing_limit INT not null,
	commission_percentage DECIMAL (5,2) not null,
	features VARCHAR (255) null,
	-- Column-level constraints
	check (monthly_fee > 0.0),
	check (product_listing_limit > 0),
	check (commission_percentage > 0.0),
	-- Table-level constraints
	primary key (plan_id)
);


-- ***** Part B: SQL DDL
-- 5. Write SQL to create the Vendor table with:
-- **vendor table 
create table if not exists vendor (
	vendor_id INT not null auto_increment,
	vat_number VARCHAR (20) unique not null,
	subscription_plan_id INT not null,
	business_name VARCHAR (150) not null,
	user_id INT not null,
	primary key (vendor_id),
	constraint fk_subscription_plan
		foreign key (subscription_plan_id)
		references subscription_plan (plan_id)
		on delete restrict
		on update cascade,
	constraint fk_user_vendor
		foreign key (user_id)
		references user (user_id)
		on delete cascade
		on update cascade
);


-- **customer table 
create table if not exists customer (
	customer_id INT not null auto_increment,
	user_id INT not null,
	primary key (customer_id),
	constraint fk_user_customer
		foreign key (user_id)
		references user (user_id)
		on delete cascade
		on update cascade
);


-- **product table 
create table if not exists product (
	product_id INT not null auto_increment,
	product_name VARCHAR (150) not null,
	brand VARCHAR (150) not null,
	base_price DECIMAL (7,2) not null,
	description TEXT null,
	status BOOLEAN not null,
	vendor_id INT not null,
    -- Column-level constraints
	check (base_price > 0.0),
	constraint fk_vendor_product
		foreign key (vendor_id)
		references vendor (vendor_id)
		on delete restrict
		on update cascade,
	-- Table-level constraints
	primary key (product_id)
);


-- **warehouse table 
create table if not exists warehouse (
	warehouse_id INT not null auto_increment,
	warehouse_name VARCHAR (150) not null,
	location VARCHAR (255) not null,
	capacity INT not null,
	-- Column-level constraints
	check (capacity > 0),
	-- Table-level constraints
	primary key (warehouse_id)
);


-- **product_warehouse table (Junction Table)
create table if not exists product_warehouse (
	product_warehouse_id INT not null auto_increment,
	warehouse_id INT not null,
	product_id INT not null,
	product_stock_total int not null,
	-- Column-level constraints
	check (product_stock_total > 0),
	-- Table-level constraints
	primary key (product_warehouse_id),
	constraint fk_warehouse_product_warehouse
		foreign key (warehouse_id)
		references warehouse (warehouse_id)
		on delete restrict
		on update cascade,
	constraint fk_product_product_warehouse
		foreign key (product_id)
		references product (product_id)
		on delete restrict
		on update cascade
);


-- **category table 
create table if not exists category (
	category_id INT not null auto_increment,
	category_name VARCHAR (150) not null,
	description TEXT null,
	primary key (category_id)
);


-- *****7. Create a ProductCategory junction table to handle M:N relationship.
-- **product_category table (Junction Table)
create table if not exists product_category (
	product_category_id INT not null auto_increment,
	product_id INT not null,
	category_id INT not null,
	primary key (product_category_id),
	constraint fk_product_product_category
		foreign key (product_id)
		references product (product_id)
		on delete restrict
		on update cascade,
	constraint fk_category_product_category
		foreign key (category_id)
		references category (category_id)
		on delete restrict
		on update cascade
);


-- **product_rating table
create table if not exists product_rating (
	product_rating_id INT not null auto_increment,
	rating INT not null,
	review TEXT null,
	product_id INT not null,
	customer_id INT null,
	primary key (product_rating_id),
	constraint fk_product_product_id
		foreign key (product_id)
		references product (product_id)
		on delete restrict
		on update cascade,
	constraint fk_customer_customer_id
		foreign key (customer_id)
		references customer (customer_id)
		on delete set null
		on update cascade	
);


-- *****6. Create the ProductVariation table with:
-- **product_variation table
create table if not exists product_variation (
	product_variation_id INT NOT null auto_increment,
	product_id INT NOT null,
	size VARCHAR (50) null,
	color VARCHAR (30) null,
	additional_price DECIMAL (7,2) NOT null,
	SKU VARCHAR (50) NOT null,
	product_variation_stock INT NOT null,
	primary key (product_variation_id),
	constraint fk_product_product_variation
		foreign key (product_id)
		references product (product_id)
		on delete cascade
		on update cascade
);


-- **order_status table
create table if not exists order_status (
	order_status_id INT NOT null auto_increment,
	order_status VARCHAR (20) NOT null,
	is_active BOOLEAN NOT null,
	primary key (order_status_id)
);


-- **product_order table
create table if not exists product_order (
	order_id INT NOT null auto_increment,
	customer_id INT null,
	order_date DATE NOT null,
	order_status_id INT null,
	total_amount DECIMAL (9,2) NOT null,
	primary key (order_id),
	constraint fk_customer_product_order
		foreign key (customer_id)
		references customer (customer_id)
		on delete set null
		on update cascade,
	constraint fk_order_status_product_order
		foreign key (order_status_id)
		references order_status (order_status_id)
		on delete set null
		on update cascade
);


-- **order_item table
create table if not exists order_item (
	order_item_id INT NOT null auto_increment,
	order_id INT NOT null,
	product_variation_id INT null,
	quantity INT NOT null,
	unit_price DECIMAL (7,2) NOT null,
	pv_additional_price DECIMAL (7,2) NOT null,
	product_id INT NOT null,
	price_subtotal DECIMAL (7,2) NOT null,
	primary key (order_item_id),
	constraint fk_order_order_item
		foreign key (order_id)
		references product_order (order_id)
		on delete cascade
		on update cascade,
	constraint fk_product_order_item
		foreign key (product_id)
		references product (product_id)
		on delete cascade
		on update cascade,
	constraint fk_product_variation_order_item
		foreign key (product_variation_id)
		references product_variation (product_variation_id)
		on delete set null
		on update cascade
);


-- **payment_method table
create table if not exists payment_method (
	payment_method_id INT NOT null auto_increment,
	payment_method VARCHAR (15) NOT null,
	primary key (payment_method_id)
);


-- **payment_status table
create table if not exists payment_status (
	payment_status_id INT NOT null auto_increment,
	payment_status VARCHAR (15) NOT null,
	primary key (payment_status_id)
);


-- **payment table
create table if not exists payment (
	payment_id INT NOT null auto_increment,
	order_id INT NOT null,
	payment_method INT null,
	amount DECIMAL (9,2) NOT null,
	payment_date DATETIME NOT null,
	payment_status INT null,
	primary key (payment_id),
	constraint fk_order_payment
		foreign key (order_id)
		references product_order (order_id)
		on delete cascade
		on update cascade,
	constraint fk_payment_method_payment
		foreign key (payment_method)
		references payment_method (payment_method_id)
		on delete set null
		on update cascade,
	constraint fk_payment_status_payment
		foreign key (payment_status)
		references payment_status (payment_status_id)
		on delete set null
		on update cascade
);


-- **return_status table
create table if not exists return_status (
	return_status_id INT NOT null auto_increment,
	return_status VARCHAR (15) NOT null,
	primary key (return_status_id)
);


-- **order_return table
create table if not exists order_return (
	order_return_id INT NOT null auto_increment,
	reason TEXT null,
	return_status INT null,
	request_date DATE NOT null,
	return_count INT NOT null,
	primary key (order_return_id),
	constraint fk_return_status_order_return
		foreign key (return_status)
		references return_status (return_status_id)
		on delete set null
		on update cascade
);


-- **order_return_item table
create table if not exists order_return_item (
	order_return_item_id INT NOT null auto_increment,
	order_id INT null,
	return_id INT NOT null,
	order_item_id INT null,
	primary key (order_return_item_id),
	constraint fk_order_order_return_item
		foreign key (order_id)
		references product_order (order_id)
		on delete set null 
		on update cascade,
	constraint fk_order_return_order_return_item
		foreign key (return_id)
		references order_return (order_return_id)
		on delete cascade 
		on update cascade,
	constraint fk_order_item_order_return_item
		foreign key (order_item_id)
		references order_item (order_item_id)
		on delete set null
		on update cascade
);


-- **discount_campaign table
create table if not exists discount_campaign (
	discount_campaign_id INT NOT null auto_increment,
	start_date DATE NOT null,
	end_date DATE NOT null,
	description TEXT null,
	is_active BOOLEAN NOT null,
	vendor_id INT null,
	created_at DATE NOT null,
	primary key (discount_campaign_id),
	constraint fk_vendor_discount_campaign
		foreign key (vendor_id)
		references vendor (vendor_id)
		on delete set null
		on update cascade
);


-- **discount table
create table if not exists discount (
	discount_id INT NOT null auto_increment,
	campaign_id INT null,
	discount_type ENUM ('fixed', 'percentage') NOT null,
	discount_value DECIMAL (7,2) NOT null,
	minimum_order_amount INT NOT null,
	max_usage INT null,
	uses_count INT null,
	primary key (discount_id),
	constraint fk_campaign_discount
		foreign key (campaign_id)
		references discount_campaign (discount_campaign_id)
		on delete set null
		on update cascade
);

show tables;
-- **product_discount_campaign table
create table if not exists product_discount_campaign (
	product_campaign_id INT NOT null auto_increment,
	product_id INT NOT null,
	campaign_id INT NOT null,
	discount_id INT null,
	campaign_price DECIMAL (7,2) NOT null,
	primary key (product_campaign_id),
	constraint fk_product_product_discount_campaign
		foreign key (product_id)
		references product (product_id)
		on delete cascade
		on update cascade,
	constraint fk_campaign_product_discount_campaign
		foreign key (campaign_id)
		references discount_campaign (discount_campaign_id)
		on delete cascade
		on update cascade,
	constraint fk_discount_product_discount_campaign
		foreign key (discount_id)
		references discount (discount_id)
		on delete set null	-- If a discount-record is deleted from the parent table, then here it will become null
		on update cascade
);






-- *** Insert Data into Tables ***

-- Table-1
-- Insert data (**user_type**)
insert into user_type (user_type) values ('customer'), ('vendor');


-- Table-2
-- Insert data (**user**)
insert into user (user_fullname, email, phone, account_status, registration_date, user_type_id) values 
('Duffy Keeley', 'dkeeley0@naver.com', '695-337-0497', false, '2023-07-26', 1),	-- 1; customer
('Ofelia Clace', 'oclace0@icio.us', '132-640-3075', true, '2024-02-08', 1),	-- 2; customer
('Kora Leagas', 'kleagas1@devhub.com', '561-312-2132', false, '2024-04-26', 2),	-- 3; vendor
('Myrwyn Fishley', 'mfishley2@squidoo.com', '706-598-7032', true, '2016-06-17', 2),	-- 4; vendor 
('Kakalina Jeaffreson', 'kjeaffreson3@amazon.co.uk', '178-295-5461', true, '2017-12-27', 1), -- 5; customer
('Lanette Yeldon', 'lyeldon4@ebay.co.uk', '856-112-7803', false, '2011-04-16', 1), -- 6; customer
('Rochette Palatino', 'rpalatino5@virginia.edu', '318-526-1703', true, '2017-03-09', 2), -- 7; vendor 
('Worthington Emtage', 'wemtage6@weather.com', '692-310-0094', true, '2012-05-04', 2), -- 8; vendor 
('Prue Fitzjohn', 'pfitzjohn7@google.es', '335-587-4125', true, '2023-10-11', 2); -- 9; vendor 

-- *****14. Delete a customer whose status is "Inactive".
-- View all the inactive customers
desc customer;
desc user;
select cust.customer_id, u.user_id, u.user_fullname, u.email, u.phone, u.account_status, ut.user_type
from customer cust
left join user u on cust.user_id = u.user_id
left join user_type ut on u.user_type_id = ut.user_type_id
where account_status = false; -- false = 'inactive'

-- Delete a user named 'Duffy Keeley' whose user_id=1, customer_id=1
delete from user where user_id = 1;

-- Verify if the record is deleted
select * from user where user_id = 1; -- If the record gets deleted successfully, the query won't return any result


-- Table-3
-- Insert data (**address**)
INSERT INTO address (house_no, street_name, thana, city, district) VALUES
('12/A', 'Road 5, Dhanmondi R/A', 'Dhanmondi', 'Dhaka', 'Dhaka'), -- 1
('45', 'Lake Circus Road', 'Kalabagan', 'Dhaka', 'Dhaka'), -- 2
('78/B', 'Agrabad C/A', 'Double Mooring', 'Chattogram', 'Chattogram'), -- 3
('101', 'Sheikh Mujib Road', 'Kotwali', 'Chattogram', 'Chattogram'), -- 4
('22/3', 'Shahjalal Uposhohor, Block C', 'Sylhet Sadar', 'Sylhet', 'Sylhet'), -- 5
('9', 'Sonadanga Residential Area, Road 2', 'Sonadanga', 'Khulna', 'Khulna'), -- 6
('55/C', 'Kazla Road', 'Boalia', 'Rajshahi', 'Rajshahi'), -- 7
('14', 'Jhawtola Main Road', 'Kotwali', 'Cumilla', 'Cumilla'), -- 8
('63/1', 'Mymensingh Road', 'Sadar', 'Gazipur', 'Gazipur'), -- 9
('88', 'College Road, Housing Estate', 'Sadar', 'Barishal', 'Barishal'); -- 10


-- Table-4
-- Insert data (**user_address**)
insert into user_address (user_id, address_id, address_type) values 
(1, 1, 'home'),
(1, 2, 'office'),
(2, 3, 'home'),
(3, 4, 'office'),
(3, 5, 'home'),
(4, 5, 'home'),
(5, 5, 'home'),
(5, 6, 'office'),
(6, 7, 'home'),
(7, 8, 'office'),
(8, 9, 'office'),
(9, 10, 'home'),
(8, 10, 'home');


-- *****Part C: SQL DML
-- 9. Insert a new subscription plan named Standard, fee 3000, product limit 200, commission 8%.
-- Table-5
-- Insert data (**subscription_plan**)
insert into subscription_plan (plan_name, monthly_fee, product_listing_limit, commission_percentage, features) values
('Standard', 3000, 200, 8, '3 warehouses access, Basic inventory tracking, Low stock alert'),
('Pro', 5000, 400, 5, '10 warehouses access, Automated stock updates, Inventory transfer between warehouses'),
('Enterprise', 1000, 20000, 3, 'Unlimited warehouses access, Basic inventory tracking, 24/7 customer support');


-- Table-6
-- Insert data (**vendor**)
-- *****10. Insert a vendor named TechZone Ltd. under the Standard plan.
insert into vendor (vat_number, subscription_plan_id, business_name, user_id) values
('0012345678901', 1, 'TechZone Ltd', 3),
('0123456789012', 1, 'TechNova Bangladesh Ltd', 4),
('0034567890123', 3, 'Digital Dhara Solutions', 7),
('0045678901234', 2, 'ByteCraft Technologies BD', 8),
('0056789012345', 2, 'SmartLink Innovations Ltd.', 9);
select * from vendor;

-- *****Part D: SQL Queries (DQL)
-- 15. Display all vendors with their plan name and commission percentage.
-- Note: This aforementioned query require the data combined the 'user', 'user_type', 'vendor', 'subscription_plan' tables
select v.vendor_id, u.user_fullname, u.email, u.phone, u.account_status, u.registration_date as 'Joining Date',
v.business_name, v.vat_number, sp.plan_name, sp.commission_percentage
from vendor v
left join user u on v.user_id = u.user_id
left join user_type ut on u.user_type_id = ut.user_type_id
left join subscription_plan sp on v.subscription_plan_id = sp.plan_id;

-- Table-7
-- Insert data (**customer**)
insert into customer (user_id) values (1), (2), (5), (6);


-- Table-8
-- Insert data (**product**)
INSERT INTO product (product_name, brand, base_price, description, status, vendor_id) VALUES
('Nova X15 Laptop', 'TechNova BD', 75000.00, '15.6-inch FHD laptop with Intel Core i5, 8GB RAM, 512GB SSD.', TRUE, 1), -- 1
('ByteCraft Wireless Mouse', 'ByteCraft', 1200.00, 'Ergonomic 2.4GHz wireless mouse with adjustable DPI.', TRUE, 1), -- 2
('SmartLink WiFi Router AC1200', 'SmartLink', 3500.00, 'Dual-band AC1200 high-speed wireless router.', TRUE, 2), -- 3
('NextGen Pro Mechanical Keyboard', 'NextGen', 4500.00, 'RGB backlit mechanical keyboard with blue switches.', TRUE, 5), -- 4
('Digital Dhara 1TB External HDD', 'Digital Dhara', 6200.00, 'Portable USB 3.0 external hard drive with 1TB storage.', TRUE, 3), -- 5
('TechNova 24-inch LED Monitor', 'TechNova BD', 18500.00, '24-inch Full HD IPS LED monitor with HDMI and VGA.', TRUE, 5), -- 6
('ByteCraft USB-C Hub 6-in-1', 'ByteCraft', 2800.00, 'Multiport USB-C hub with HDMI, USB 3.0, and SD card support.', TRUE, 4), -- 7
('SmartLink Bluetooth Speaker S20', 'SmartLink', 3200.00, 'Portable waterproof Bluetooth speaker with deep bass.', TRUE, 4), -- 8
('NextGen 256GB NVMe SSD', 'NextGen', 5400.00, 'High-speed 256GB NVMe SSD for desktops and laptops.', TRUE, 5), -- 9
('Digital Dhara Smartwatch D5', 'Digital Dhara', 8900.00, 'Fitness smartwatch with heart-rate monitor and AMOLED display.', TRUE, 2), -- 10
('TechNova Tab X10', 'TechNova BD', 22000.00, '10.1-inch Android tablet with 4GB RAM and 64GB storage.', FALSE, 2), -- 11
('ByteCraft Gaming Headset Pro', 'ByteCraft', 3800.00, 'Over-ear RGB gaming headset with noise-cancelling mic.', FALSE, 4), -- 12
('SmartLink 5G Pocket Router', 'SmartLink', 12500.00, 'Portable 5G LTE pocket router with 3000mAh battery.', FALSE, 3), -- 13
('NextGen Mini PC Core i7', 'NextGen', 68000.00, 'Compact mini PC with Intel Core i7, 16GB RAM, 1TB SSD.', FALSE, 1); -- 14


-- *****11. Insert a product "Smartphone" under TechZone Ltd.
INSERT INTO product (product_name, brand, base_price, description, status, vendor_id) VALUES
('Smartphone', 'TechZone Ltd', 45000.00, 'Latest 5G smartphone with AMOLED display, 8GB RAM, and 256GB storage.', TRUE, 1); -- 15

select * from product;

-- 16. Show all products with total available stock across all warehouses.
select * from product_warehouse;

select p.product_id, p.product_name, p.brand , GROUP_CONCAT(pw.warehouse_id separator ', '), SUM(pw.product_stock_total)
from product_warehouse pw
left join product p on pw.product_id = p.product_id
group by pw.product_id;


-- Table-9
-- Insert data (**warehouse**)
INSERT INTO warehouse (warehouse_name, location, capacity) VALUES
('Dhaka Central Fulfillment Center', 'Tejgaon Industrial Area, Dhaka, Bangladesh', 50000), -- Dhaka Warehouse
('Chattogram Port Warehouse', 'Agrabad Commercial Area, Chattogram, Bangladesh', 75000),
('Gazipur Distribution Hub', 'Tongi, Gazipur, Bangladesh', 60000),
('Narayanganj Logistics Center', 'Fatullah, Narayanganj, Bangladesh', 45000),
('Sylhet Storage Facility', 'Khadimnagar, Sylhet, Bangladesh', 30000),
('Khulna Regional Warehouse', 'Khalishpur Industrial Area, Khulna, Bangladesh', 40000),
('Rajshahi Supply Chain Depot', 'Boalia, Rajshahi, Bangladesh', 28000),
('Cumilla Transit Warehouse', 'EPZ Area, Cumilla, Bangladesh', 35000),
('Barishal Riverport Storage', 'Band Road, Barishal, Bangladesh', 25000),
('Rangpur Northern Distribution Center', 'Modern Mor, Rangpur, Bangladesh', 32000);


-- *****8. Create the WarehouseStock table to manage stock per warehouse.
-- Table-10
-- Insert data (**product_warehouse**)
INSERT INTO product_warehouse (warehouse_id, product_id, product_stock_total) VALUES
(1, 1, 120),
(1, 2, 300),
(2, 3, 150),
(2, 4, 200),
(3, 5, 180),
(3, 6, 90),
(4, 7, 250),
(4, 8, 175),
(5, 9, 140),
(5, 10, 110),
(6, 11, 60),
(6, 12, 85),
(7, 13, 45),
(7, 14, 70),
(8, 1, 210),
(8, 5, 160),
(9, 3, 130),
(9, 9, 95),
(10, 2, 220),
(10, 6, 105);

-- *****13. Update stock of this variation in Dhaka warehouse to 25 units.
select * from warehouse;
select * from product;
select * from product_variation;
-- Task-1: First insert the product variation record in the product_warehouse table
-- Note: While creating the only product variation record of "Smartphone", it's product_variation_stock was 50, 
-- thus the total_product_stock of this item will be 50 in the product_warehouse junction table.
INSERT INTO product_warehouse (warehouse_id, product_id, product_stock_total) VALUES
(1, 15, 50);

select * from product_warehouse;

-- Now update the product_variation_stock first, then update the product_stock in the product_warehouse
update product_variation
set product_variation_stock = 25
where SKU = 'SP128B';

update product_warehouse
set product_stock_total = 25
where product_id = 15;


-- Table-11
-- Insert data (**category**)
INSERT INTO category (category_name, description) VALUES
('Laptops & Computers', 'Desktops, laptops, and related computer systems.'), -- 1
('Computer Accessories', 'Keyboards, mice, webcams, and other peripherals.'), -- 2
('Networking Devices', 'Routers, switches, modems, and networking equipment.'), -- 3
('Storage Devices', 'Internal and external storage solutions including SSDs and HDDs.'), -- 4
('Monitors & Displays', 'LED, LCD, and high-resolution computer monitors.'), -- 5
('Audio Devices', 'Headphones, speakers, and sound systems.'), -- 6
('Smart Gadgets', 'Smartwatches, smart home devices, and IoT products.'), -- 7
('Mobile Accessories', 'Chargers, power banks, cables, and phone accessories.'), -- 8
('Gaming Equipment', 'Gaming keyboards, mice, headsets, and accessories.'), -- 9
('Office Electronics', 'Printers, scanners, and other office tech equipment.'); -- 10


-- Table-12
-- Insert data (**product_category**)
INSERT INTO product_category (product_id, category_id) VALUES
(1, 1),   -- Laptop → Laptops & Computers
(1, 4),   -- Laptop → Storage Devices
(2, 2),   -- Mouse → Computer Accessories
(3, 3),   -- Router → Networking Devices
(4, 9),   -- Mechanical Keyboard → Gaming Equipment
(4, 2),   -- Mechanical Keyboard → Computer Accessories
(5, 4),   -- External HDD → Storage Devices
(6, 5),   -- Monitor → Monitors & Displays
(7, 2),   -- USB-C Hub → Computer Accessories
(8, 6),   -- Bluetooth Speaker → Audio Devices
(9, 4),   -- NVMe SSD → Storage Devices
(10, 7),  -- Smartwatch → Smart Gadgets
(11, 7),  -- Tablet → Smart Gadgets
(11, 1),  -- Tablet → Laptops & Computers
(12, 9),  -- Gaming Headset → Gaming Equipment
(12, 6),  -- Gaming Headset → Audio Devices
(13, 3),  -- 5G Pocket Router → Networking Devices
(14, 1),  -- Mini PC → Laptops & Computers
(14, 4),  -- Mini PC → Storage Devices
(6, 10);  -- Monitor → Office Electronics


-- Table-13
-- Insert data (**product_rating**)
INSERT INTO product_rating (rating, review, product_id, customer_id) VALUES
(5, 'Excellent performance and very fast SSD.', 1, 1),
(4, 'Good laptop for office work.', 1, 2),
(5, 'Very smooth and responsive mouse.', 2, 3),
(3, 'Works fine but build quality could be better.', 2, 4),
(4, 'Stable internet connection and easy setup.', 3, 1),
(5, 'Perfect for gaming and typing.', 4, 2),
(4, 'RGB lights look amazing.', 4, 3),
(5, 'Fast data transfer speed.', 5, 4),
(4, 'Display quality is sharp and clear.', 6, 1),
(3, 'Sound quality is decent for the price.', 8, 2),
(5, 'Super fast boot time after installing this SSD.', 9, 3),
(4, 'Battery backup is good and display is vibrant.', 10, 4),
(3, 'Tablet performance is average.', 11, 1),
(4, 'Comfortable headset for long gaming sessions.', 12, 2),
(5, 'Very powerful mini PC in compact size.', 14, 3),
(2, 'Router signal drops occasionally.', 13, 4),
(4, 'Good value for money external HDD.', 5, 1),
(5, 'Crystal clear monitor display.', 6, 2),
(4, 'Nice design and comfortable grip.', 2, 3),
(5, 'Highly recommended for tech enthusiasts.', 1, 4);


-- Table-14
-- Insert data (**product_variation**)
INSERT INTO product_variation (product_id, size, color, additional_price, SKU, product_variation_stock) VALUES
(1, NULL, 'Silver', 2000.00, 'TNX15-SLV', 50), -- 1
(1, NULL, 'Black', 2500.00, 'TNX15-BLK', 30), -- 2
(2, NULL, 'Black', 100.00, 'BCMOUSE-BLK', 150), -- 3
(2, NULL, 'White', 120.00, 'BCMOUSE-WHT', 120), -- 4
(3, NULL, 'Black', 500.00, 'SLR-AC1200-BLK', 80), -- 5
(3, NULL, 'White', 600.00, 'SLR-AC1200-WHT', 60), -- 6
(4, NULL, 'Black', 700.00, 'NGKEY-RGB-BLK', 90), -- 7
(4, NULL, 'White', 700.00, 'NGKEY-RGB-WHT', 70), -- 8
(5, NULL, 'Silver', 300.00, 'DDHDD-1TB-SLV', 100), -- 9
(6, 24.00, 'Black', 1000.00, 'TNMON-24-BLK', 40), -- 10
(7, NULL, 'Gray', 150.00, 'BCHUB-6IN1-GRY', 60), -- 11
(8, NULL, 'Blue', 200.00, 'SLSPK-S20-BLU', 80), -- 12
(9, NULL, 'Silver', 500.00, 'NGSSD-256GB-SLV', 70), -- 13
(10, NULL, 'Black', 1000.00, 'DDSW-D5-BLK', 50), -- 14
(11, 10.10, 'Black', 1500.00, 'TBL-X10-BLK', 60), -- 15
(12, NULL, 'Black', 350.00, 'GHEAD-PRO-BLK', 90), -- 16
(13, NULL, 'White', 800.00, 'SL5GPRTR-WHT', 40), -- 17
(14, NULL, 'Black', 3000.00, 'NGMINIPC-I7-BLK', 30), -- 18
(14, NULL, 'Silver', 3200.00, 'NGMINIPC-I7-SLV', 25), -- 19
(5, NULL, 'Black', 350.00, 'DDHDD-1TB-BLK', 90); -- 20


-- 12. Insert a variation for Smartphone: ● Size: 128GB ● Color: Black ● SKU: SP128B
INSERT INTO product_variation (product_id, size, color, additional_price, SKU, product_variation_stock) VALUES
(15, '128GB', 'Black', 0.00, 'SP128B', 50); -- 21
-- View the newly inserted product_variation of the "Smartphone" record of product table
select p.product_id, p.product_name, pv.product_variation_id, pv.size, pv.color, 
pv.additional_price, pv.SKU, pv.product_variation_stock
from product_variation pv
left join product p on pv.product_id = p.product_id
where SKU = 'SP128B';


-- 24. Identify vendors who exceeded their product listing limit.
-- Task: 1. Summed up all the products of each vendor
-- Task: 2. Grouped up all the product variation items under those products of each vendor
-- Task: 3. Modify the "Standard" subscription_plan's product_listing_limit = 3 to demonstrat vendors who has exceeded their product listing limit.
select * from subscription_plan sp ;

-- Modify the "Standard" subscription_plan's product_listing_limit = 3 to demonstrat vendors who has 
-- exceeded their product listing limit.
update subscription_plan sp
set sp.product_listing_limit = 3
where sp.plan_name = "Standard";

select v.vendor_id, COUNT(p.product_id) "Total Products", sp.plan_name "Subscription Plan", sp.product_listing_limit 
from product p 
left join vendor v on p.vendor_id = v.vendor_id
left join subscription_plan sp on v.subscription_plan_id = sp.plan_id 
group by v.vendor_id
having count(p.product_id) > sp.product_listing_limit;

-- Table-15
-- Insert data (**discount_campaign**)
INSERT INTO discount_campaign (start_date, end_date, description, is_active, vendor_id, created_at) VALUES
('2026-03-01', '2026-03-10', 'Summer Sale on laptops and accessories', TRUE, 1, '2026-02-25'), -- 1
('2026-03-05', '2026-03-15', 'Special discount on gaming equipment', TRUE, 2, '2026-03-01'), -- 2
('2026-03-10', '2026-03-20', 'Buy 1 Get 1 free on USB-C hubs', FALSE, 3, '2026-03-05'), -- 3
('2026-03-12', '2026-03-22', 'Smart gadgets clearance sale', TRUE, 4, '2026-03-06'), -- 4
('2026-03-15', '2026-03-25', 'Monitor and display discount week', FALSE, 5, '2026-03-10'), -- 5
('2026-03-18', '2026-03-28', 'External storage devices sale', TRUE, 1, '2026-03-12'), -- 6
('2026-03-20', '2026-03-30', 'Gaming accessories flash sale', TRUE, 2, '2026-03-15'), -- 7
('2026-03-22', '2026-04-01', 'Tablet and smartwatch special offer', FALSE, 3, '2026-03-18'), -- 8
('2026-03-25', '2026-04-05', 'Headset and audio devices promo', TRUE, 4, '2026-03-20'), -- 9
('2026-03-28', '2026-04-07', 'Mini PCs and high-end laptops campaign', TRUE, 5, '2026-03-22'); -- 10


-- Table-16
-- Insert data (**discount**)
INSERT INTO discount (campaign_id, discount_type, discount_value, minimum_order_amount, max_usage, uses_count) VALUES
(1, 'percentage', 10.00, 2, 100, 0),
(2, 'fixed', 1500.00, 3, 50, 0),
(3, 'percentage', 15.00, 5, 200, 0),
(4, 'fixed', 800.00, 4, 150, 0),
(5, 'percentage', 20.00, 6, 100, 0),
(6, 'fixed', 500.00, 2, 300, 0),
(7, 'percentage', 5.00, 3, 500, 0),
(8, 'fixed', 2000.00, 7, 50, 0),
(9, 'percentage', 12.50, 8, 120, 0),
(10, 'fixed', 1000.00, 10, 200, 0);


-- Table-17
-- Insert data (**product_discount_campaign**)
INSERT INTO product_discount_campaign (product_id, campaign_id, discount_id, campaign_price) VALUES
(1, 1, 1, 67500.00),  -- Laptop with 10% discount
(2, 2, 2, 9700.00),   -- Mouse with fixed 1500 BDT off
(3, 3, 3, 12750.00),  -- Router with 15% discount
(4, 4, 4, 3800.00),   -- Mechanical keyboard with fixed 800 BDT off
(5, 5, 5, 4960.00),   -- External HDD with 20% discount
(6, 6, 6, 17500.00),  -- Monitor with fixed 500 BDT off
(7, 7, 7, 285.00),    -- USB-C Hub with 5% discount
(8, 8, 8, 3000.00),   -- Bluetooth speaker with fixed 2000 BDT off
(9, 9, 9, 4725.00),   -- NVMe SSD with 12.5% discount
(10, 10, 10, 7900.00);  -- Smartwatch with fixed 1000 BDT off


-- Table-18
-- Insert data (**order_status**)
INSERT INTO order_status (order_status, is_active) values 
('Pending', true), 
('Confirmed', true), 
('Shipped', true),
('Delivered', true), 
('Cancelled', true); 


-- Table-19
-- Insert data (**product_order**)
INSERT INTO product_order (customer_id, order_date, order_status_id, total_amount) VALUES
(1, '2026-03-01', 1, 79600.00),
(2, '2026-03-02', 2, 4270.00),
(3, '2026-03-02', 3, 9200.00),
(4, '2026-03-03', 4, 16400.00),
(1, '2026-03-04', 5, 23400.00),
(2, '2026-03-05', 1, 85800.00),
(3, '2026-03-05', 2, 10000.00),
(4, '2026-03-06', 3, 20300.00),
(1, '2026-03-07', 4, 29400.00),
(2, '2026-03-08', 5, 84300.00),
(3, '2026-03-08', 1, 72500.00),
(4, '2026-03-09', 2, 18300.00),
(1, '2026-03-10', 3, 77000.00),
(2, '2026-03-11', 4, 8000.00),
(3, '2026-03-12', 5, 10200.00),
(4, '2026-03-13', 1, 2640.00),
(1, '2026-03-14', 2, 6500.00),
(2, '2026-03-15', 3, 19500.00),
(3, '2026-03-16', 4, 79600.00),
(4, '2026-03-17', 5, 4270.00);

update product_order po
set order_date = '2026-01-15'
where po.order_id = 20;

-- *****17. List all orders placed in the last 30 days.
select po.order_id, u.user_fullname, po.order_date, os.order_status, po.total_amount
from product_order po
left join customer cust on po.customer_id = cust.customer_id
left join user u on cust.user_id = u.user_id
left join order_status os on po.order_status_id = os.order_status_id
where po.order_date >= NOW() - INTERVAL 30 DAY;



-- *****21. Calculate total revenue per vendor.
select order_id, customer_id,  from product_order;

-- Table-20
-- Insert data (**order_item**)
INSERT INTO order_item (order_id, product_variation_id, product_id, quantity, unit_price, pv_additional_price, price_subtotal) VALUES
(1, 1, 1, 1, 75000.00, 2000.00, 77000.00),
(1, 3, 2, 2, 1200.00, 100.00, 2600.00),
(2, 4, 2, 1, 1200.00, 120.00, 1320.00),
(2, 11, 7, 1, 2800.00, 150.00, 2950.00),
(3, 5, 3, 1, 3500.00, 500.00, 4000.00),
(3, 7, 4, 1, 4500.00, 700.00, 5200.00),
(4, 9, 5, 2, 6200.00, 300.00, 13000.00),
(4, 12, 8, 1, 3200.00, 200.00, 3400.00),
(5, 10, 6, 1, 18500.00, 1000.00, 19500.00),
(5, 3, 2, 3, 1200.00, 100.00, 3900.00),
(6, 2, 1, 1, 75000.00, 2500.00, 77500.00),
(6, 16, 12, 2, 3800.00, 350.00, 8300.00),
(7, 6, 3, 1, 3500.00, 600.00, 4100.00),
(7, 13, 9, 1, 5400.00, 500.00, 5900.00),
(8, 8, 4, 2, 4500.00, 700.00, 10400.00),
(8, 14, 10, 1, 8900.00, 1000.00, 9900.00),
(9, 15, 11, 1, 22000.00, 1500.00, 23500.00),
(9, 11, 7, 2, 2800.00, 150.00, 5900.00),
(10, 17, 13, 1, 12500.00, 800.00, 13300.00),
(10, 18, 14, 1, 68000.00, 3000.00, 71000.00),
(11, 19, 14, 1, 68000.00, 3200.00, 71200.00),
(11, 3, 2, 1, 1200.00, 100.00, 1300.00),
(12, 20, 5, 2, 6200.00, 350.00, 13100.00),
(12, 7, 4, 1, 4500.00, 700.00, 5200.00),
(13, 1, 1, 1, 75000.00, 2000.00, 77000.00),
(14, 5, 3, 2, 3500.00, 500.00, 8000.00),
(15, 12, 8, 3, 3200.00, 200.00, 10200.00),
(16, 4, 2, 2, 1200.00, 120.00, 2640.00),
(17, 9, 5, 1, 6200.00, 300.00, 6500.00),
(18, 10, 6, 1, 18500.00, 1000.00, 19500.00),
(19, 1, 1, 1, 75000.00, 2000.00, 77000.00),
(19, 3, 2, 2, 1200.00, 100.00, 2600.00),
(20, 4, 2, 1, 1200.00, 120.00, 1320.00),
(20, 11, 7, 1, 2800.00, 150.00, 2950.00);

select * from order_item;
where product_variation_id = 1;

-- *****18. Find top 5 best-selling product variations.
select oi.product_variation_id, SUM(oi.quantity) as TotalSold
from order_item oi
group by oi.product_variation_id
order by TotalSold desc
limit 5;

-- *****Part E: Advanced SQL
-- 21. Calculate total revenue per vendor.
-- Tasks: 1. Find out all the orders that are being delivered to the customer.
-- Task: 2. Grouped all the order items of those orders.
-- Task: 3. Then grouped all the product_variation_ids, product_ids, theirs bases prices, additional prices, quantities in separate columns.
-- Task: 4. Then grouped the addition of their base_prices & additional_prices. Lastly sum the grouped prices & labelled as "Total Revenue"   
select v.vendor_id, GROUP_CONCAT(oi.order_item_id), GROUP_CONCAT(pv.product_variation_id), 
GROUP_CONCAT(p.product_id), GROUP_CONCAT(oi.unit_price), GROUP_CONCAT(oi.pv_additional_price), GROUP_CONCAT(oi.quantity), 
SUM((oi.unit_price + oi.pv_additional_price) * oi.quantity) as "Total Revenue"
from product_order po
left join order_status os on po.order_status_id = os.order_status_id
left join order_item oi on po.order_id = oi.order_id
left join product_variation pv on oi.product_variation_id = pv.product_variation_id
left join product p on pv.product_id = p.product_id 
left join vendor v on p.vendor_id = v.vendor_id
where os.order_status = "Delivered"
group by v.vendor_id;


select * from product_order po;

-- View the product_variation_id with their unit price & additional price summed up together 
select p.product_id, GROUP_CONCAT(pv.product_variation_id), GROUP_CONCAT(p.base_price), GROUP_CONCAT(pv.additional_price), 
GROUP_CONCAT((p.base_price + pv.additional_price) separator ',  ') 
as "Combined Price"
from product_variation pv
left join product p on pv.product_id = p.product_id
group by p.product_id;

-- View the product record
select * from product p
where p.product_id = 1;

-- view the product variation record
select * from product_variation pv 
where pv.product_variation_id in (1,2,3);




-- 22. Find customers who purchased from more than two vendors.
-- Task: Find total product_orders of each customer. Find their associate order items, then their product ids, 
-- those product ids have vendor ids attached. From that group the vendor ids in a separate column and add a filter using the
-- "HAVING" clause to fetch the records where the agrregated-vendor-count of each customer is more than two vendors.

select po.customer_id, u.user_fullname "Customer Name",
GROUP_CONCAT(distinct po.order_id) "Order IDs", 
GROUP_CONCAT(oi.order_item_id) "Order Item IDs",
GROUP_CONCAT(oi.product_id) "Product IDs", GROUP_CONCAT(distinct p.vendor_id),
COUNT(distinct p.vendor_id) "Total Vendors (Included each order)"
from product_order po 
left join order_item oi on po.order_id = oi.order_id
left join product p on oi.product_id = p.product_id
left join customer cust on po.customer_id = cust.customer_id
left join user u on cust.user_id = u.user_id 
where po.customer_id is not null
group by po.customer_id
having COUNT(distinct p.vendor_id) > 2;



-- 23. Show monthly sales summary for the current year.
-- Note: For the monthly sales summary report, the important matrics are: total orders, total revenue, 
-- total items sold, average order value, total customers, total vendors, commission from vendors.
-- Task: 1. Find the total orders of each month from the product_order table whose order_status is not cancelled.
select month(po.order_date) "Month#", MONTHNAME(po.order_date) "Month",
COUNT(distinct po.order_id) "Total Orders", 
count(oi.order_item_id) "Total Items Sold",
count(distinct po.customer_id) "Total Customers", 
COUNT(distinct v.vendor_id) "Total Vendors",
SUM(po.total_amount) "Total Revenue",
(SUM(po.total_amount) / COUNT(distinct po.order_id)) "Average Order Value (AOV)"
from product_order po
left join order_status os on po.order_status_id = os.order_status_id
left join order_item oi on po.order_id = oi.order_id
left join product p on oi.product_id = p.product_id
left join vendor v on p.vendor_id = v.vendor_id
where os.order_status != "Cancelled" and YEAR(po.order_date) = YEAR(CURDATE())
group by month(po.order_date), MONTHNAME(po.order_date);


-- Table-21
-- Insert data (**payment_method**)
insert into payment_method (payment_method) values ('Card'), ('Bkash'), ('Nagad'), ('PayPal'), ('COD');


-- Table-22
-- Insert data (**payment_status**)
insert into payment_status (payment_status) values ('Pending'), ('Paid'), ('Failed'), ('Refunded');


-- Table-23
-- Insert data (**payment**)
insert into payment (order_id, payment_method, payment_date, payment_status, amount) values 
(1, 1, '2026-03-01', 1, 79600.00),
(2, 2, '2026-03-02', 2, 4270.00),
(3, 1, '2026-03-02', 2, 9200.00),
(4, 5, '2026-03-03', 2, 16400.00),
(1, 3, '2026-03-04', 2, 23400.00),
(2, 2, '2026-03-05', 1, 85800.00),
(3, 4, '2026-03-05', 2, 10000.00),
(4, 2, '2026-03-06', 3, 20300.00),
(1, 5, '2026-03-07', 2, 29400.00),
(2, 3, '2026-03-08', 1, 84300.00),
(3, 2, '2026-03-08', 1, 72500.00),
(4, 4, '2026-03-09', 2, 18300.00),
(1, 2, '2026-03-10', 2, 77000.00),
(2, 2, '2026-03-11', 4, 8000.00),
(3, 5, '2026-03-12', 4, 10200.00),
(4, 3, '2026-03-13', 1, 2640.00),
(1, 2, '2026-03-14', 2, 6500.00),
(2, 4, '2026-03-15', 2, 19500.00),
(3, 3, '2026-03-16', 2, 79600.00),
(4, 5, '2026-03-17', 1, 4270.00);


-- *****20. Retrieve orders that are delivered but payment status is not "Paid".
select po.order_id, os.order_status, pm.payment_method, ps.payment_status, pmnt.amount
from product_order po
left join order_status os on po.order_status_id = os.order_status_id
left join payment pmnt on po.order_id = pmnt.order_id
left join payment_method pm on pmnt.payment_method = pm.payment_method_id
left join payment_status ps on pmnt.payment_status = ps.payment_status_id
where os.order_status = "Delivered" and ps.payment_status != "Paid";


-- Table-24
-- Insert data (**return_status**)
select * from product_order;
insert into return_status (return_status) values ('Requested'), ('Approved'), ('Rejected'), ('Refunded');


-- Table-25
-- Insert data (**order_return**)
INSERT INTO order_return (reason, return_status, request_date, return_count) VALUES
('Received damaged product (router not powering on).', 1, '2026-03-05', 1),
('Wrong color delivered for USB-C hub.', 2, '2026-03-08', 1),
('Smartwatch battery draining too fast.', 3, '2026-03-12', 1),
('Monitor display has dead pixels.', 4, '2026-03-15', 1),
('Ordered wrong variant by mistake.', 2, '2026-03-18', 2);


-- Table-26
-- Insert data (**order_return_item**)
INSERT INTO order_return_item (order_id, return_id, order_item_id) VALUES
(5, 1, 9),
(5, 1, 10),
(10, 2, 19),
(10, 2, 20),
(13, 3, 25),
(15, 4, 27),
(20, 5, 33),
(20, 5, 34);


select * from order_return;
select * from order_return_item;
-- *****19. Show customers who requested returns.
select cust.customer_id, u.user_fullname, ort.order_return_id, rs.return_status, p.product_name
from order_return ort
left join return_status rs on ort.return_status = rs.return_status_id
left join order_return_item orit on orit.return_id = ort.order_return_id 
left join order_item oi on orit.order_item_id = oi.order_item_id
left join product p on oi.product_id = p.product_id
left join product_order po on orit.order_id = po.order_id
left join customer cust on po.customer_id = cust.customer_id
left join user u on cust.user_id = u.user_id
where rs.return_status = 'Requested';



-- *****25. Write a query using a CTE (Common Table Expression) to rank vendors based on total sales.
select * from order_item oi;

with vendor_sales as (
	select p.vendor_id, SUM(oi.price_subtotal) Total_Sales
	from order_item oi
	left join product p on oi.product_id = p.product_id
	group by p.vendor_id
)

select 
vs.vendor_id, 
vs.total_sales,
rank() over (order by vs.total_sales desc) "Rank"
from vendor_sales vs;




