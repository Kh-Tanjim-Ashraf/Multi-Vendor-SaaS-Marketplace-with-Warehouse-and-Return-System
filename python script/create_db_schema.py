import mysql.connector

# Database connection parameters (replace with your own credentials)
DB_CONFIG = {
    'host': 'localhost',
    'user': 'multi_vendor_marketplace_admin',
    'password': 'pass1234',
    'database': 'multi_vendor_saas_marketplace' # The database must already exist
}

def create_db_schema():
    """Connects to MySQL and creates database schema."""
    try:
        # Establish the connection to the MySQL server
        conn = mysql.connector.connect(**DB_CONFIG)
        # Create a cursor object to execute SQL queries
        cursor = conn.cursor()

        # SQL statement to create the 'user_type' table
        # We use IF NOT EXISTS to prevent errors if the table already exists
        create_user_type_table_query = """
            create table if not exists user_type (
                user_type_id INT not null auto_increment,
                user_type ENUM ('vendor', 'customer') not null,
                primary key (user_type_id),
                constraint unique_user_type unique(user_type)
            );
        """

        # Execute the SQL query
        cursor.execute(create_user_type_table_query)
        print("Table 'user_type' created successfully or already exists.")

        # ----------------------------------------
        # SQL statement to create the 'user' table
        create_user_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_user_table_query)
        print("Table 'user' created successfully or already exists.")

        # ----------------------------------------
        # SQL statement to create the 'address' table
        create_address_table_query = """
            create table if not exists address (
                address_id INT not null auto_increment,
                house_no VARCHAR (50) null,
                street_name VARCHAR (100) null,
                thana VARCHAR (50) null,
                city VARCHAR (50) null,
                district VARCHAR (50) null,
                primary key (address_id)
            );
        """

        # Execute the SQL query
        cursor.execute(create_address_table_query)
        print("Table 'address' created successfully or already exists.")        

        # ----------------------------------------
        # SQL statement to create the 'user_address' table
        create_user_address_table_query = """
            create table if not exists user_address (
                user_address_id INT not null auto_increment,
                user_id INT not null,
                address_id INT not null,
                address_type ENUM ('home', 'office') NOT NULL,
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
        """

        # Execute the SQL query
        cursor.execute(create_user_address_table_query)
        print("Table 'user_address' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'subscription_plan' table
        create_subscription_plan_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_subscription_plan_table_query)
        print("Table 'subscription_plan' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'vendor' table
        create_vendor_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_vendor_table_query)
        print("Table 'vendor' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'customer' table
        create_customer_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_customer_table_query)
        print("Table 'customer' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'product' table
        create_product_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_product_table_query)
        print("Table 'product' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'warehouse' table
        create_warehouse_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_warehouse_table_query)
        print("Table 'warehouse' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'product_warehouse' table
        create_product_warehouse_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_product_warehouse_table_query)
        print("Table 'product_warehouse' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'category' table
        create_category_table_query = """
            create table if not exists category (
                category_id INT not null auto_increment,
                category_name VARCHAR (150) not null,
                description TEXT null,
                primary key (category_id)
            );
        """

        # Execute the SQL query
        cursor.execute(create_category_table_query)
        print("Table 'category' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'product_category' table
        create_product_category_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_product_category_table_query)
        print("Table 'product_category' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'product_rating' table
        create_product_rating_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_product_rating_table_query)
        print("Table 'product_rating' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'product_variation' table
        create_product_variation_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_product_variation_table_query)
        print("Table 'product_variation' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'order_status' table
        create_order_status_table_query = """
            create table if not exists order_status (
                order_status_id INT NOT null auto_increment,
                order_status VARCHAR (20) NOT null,
                is_active BOOLEAN NOT null,
                primary key (order_status_id)
            );
        """

        # Execute the SQL query
        cursor.execute(create_order_status_table_query)
        print("Table 'order_status' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'product_order' table
        create_product_order_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_product_order_table_query)
        print("Table 'product_order' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'order_item' table
        create_order_item_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_order_item_table_query)
        print("Table 'order_item' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'payment_method' table
        create_payment_method_table_query = """
            create table if not exists payment_method (
                payment_method_id INT NOT null auto_increment,
                payment_method VARCHAR (15) NOT null,
                primary key (payment_method_id)
            );
        """

        # Execute the SQL query
        cursor.execute(create_payment_method_table_query)
        print("Table 'payment_method' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'payment_status' table
        create_payment_status_table_query = """
            create table if not exists payment_status (
                payment_status_id INT NOT null auto_increment,
                payment_status VARCHAR (15) NOT null,
                primary key (payment_status_id)
            );
        """

        # Execute the SQL query
        cursor.execute(create_payment_status_table_query)
        print("Table 'payment_status' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'payment' table
        create_payment_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_payment_table_query)
        print("Table 'payment' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'return_status' table
        create_return_status_table_query = """
            create table if not exists return_status (
                return_status_id INT NOT null auto_increment,
                return_status VARCHAR (15) NOT null,
                primary key (return_status_id)
            );
        """

        # Execute the SQL query
        cursor.execute(create_return_status_table_query)
        print("Table 'return_status' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'order_return' table
        create_order_return_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_order_return_table_query)
        print("Table 'order_return' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'order_return_item' table
        create_order_return_item_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_order_return_item_table_query)
        print("Table 'order_return_item' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'discount_campaign' table
        create_discount_campaign_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_discount_campaign_table_query)
        print("Table 'discount_campaign' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'discount' table
        create_discount_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_discount_table_query)
        print("Table 'discount' created successfully or already exists.")


        # ----------------------------------------
        # SQL statement to create the 'product_discount_campaign' table
        create_product_discount_campaign_table_query = """
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
        """

        # Execute the SQL query
        cursor.execute(create_product_discount_campaign_table_query)
        print("Table 'product_discount_campaign' created successfully or already exists.")

        # Commit the changes (CREATE TABLE is a DDL statement, but it's good practice)
        conn.commit()

    except mysql.connector.Error as err:
        print(f"Error: {err}")

    finally:
        # Close the cursor and connection in the finally block to ensure cleanup
        if cursor:
            cursor.close()
        if conn and conn.is_connected():
            conn.close()
            print("MySQL connection closed.")

if __name__ == "__main__":
    create_db_schema()
