-- 1. products table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price INTEGER NOT NULL
);

-- 2. orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_datetime TIMESTAMP NOT NULL
);

-- 3. order_details table
CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL
);

-- 4. daily_sales_summary table (Work Table)
CREATE TABLE daily_sales_summary (
    summary_date DATE NOT NULL,
    product_id INTEGER NOT NULL,
    total_quantity_sold INTEGER NOT NULL,
    total_sales_amount INTEGER NOT NULL,
    PRIMARY KEY (summary_date, product_id)
);
