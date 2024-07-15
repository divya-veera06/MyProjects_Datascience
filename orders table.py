import mysql.connector
from faker import Faker
import random

# Initialize Faker
fake = Faker()

# Connect to the MySQL database
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Vivek0306",
    database="storebooks1"
)

cursor = db.cursor()


# Function to generate fake data and insert into Orders table
def generate_orders_data(n):
    values = []
    for i in range(1, n + 1):
        order_id = f'order_{i:03d}'
        customer_id = f'customer_{random.randint(1, 100):03d}'  # Assuming there are 100 customers
        order_date = fake.date_this_year()
        total_amount = round(random.uniform(10.0, 500.0), 2)

        values.append(f"('{order_id}', '{customer_id}', '{order_date}', {total_amount})")

    # Create the full insert query
    insert_query = "INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount) VALUES " + ", ".join(values) + ";"

    # Execute the insert query
    cursor.execute(insert_query)

    db.commit()


# Generate and insert 100 rows of data
generate_orders_data(100)

print("100 rows of data inserted successfully")

# Close the connection
cursor.close()
db.close()
