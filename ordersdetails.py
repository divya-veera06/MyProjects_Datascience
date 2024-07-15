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

# Fetch existing ISBNs from the Books table
cursor.execute("SELECT ISBN FROM Books")
isbn_results = cursor.fetchall()
isbn_list = [isbn[0] for isbn in isbn_results]

if not isbn_list:
    print("No ISBNs found in the Books table.")
    cursor.close()
    db.close()
    exit()


# Function to generate fake data and insert into OrderDetails table
def generate_order_details_data(n):
    values = []
    for i in range(1, n + 1):
        order_id = f'order_{random.randint(1, 100):03d}'  # Assuming there are 100 orders
        isbn = random.choice(isbn_list)  # Select a random ISBN from the existing ISBNs
        quantity = random.randint(1, 5)
        price = round(random.uniform(5.0, 100.0), 2)

        values.append(f"('{order_id}', '{isbn}', {quantity}, {price})")

    # Create the full insert query
    insert_query = "INSERT INTO OrderDetails (OrderID, ISBN, Quantity, Price) VALUES " + ", ".join(values) + ";"

    # Execute the insert query
    cursor.execute(insert_query)

    db.commit()


# Generate and insert 100 rows of data
generate_order_details_data(100)

print("100 rows of data inserted successfully")

# Close the connection
cursor.close()
db.close()
