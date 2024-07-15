import mysql.connector
from faker import Faker

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


# Function to generate fake data and insert into Customers table
def generate_customers_data(n):
    values = []
    for i in range(1, n + 1):
        customer_id = f'customer_{i:03d}'
        name = fake.name()
        email = fake.email()
        address = fake.address().replace("\n", " ")

        values.append(f"('{customer_id}', '{name}', '{email}', '{address}')")

    # Create the full insert query
    insert_query = "INSERT INTO Customers (CustomerID, Name, Email, Address) VALUES " + ", ".join(values) + ";"

    # Execute the insert query
    cursor.execute(insert_query)

    db.commit()


# Generate and insert 100 rows of data
generate_customers_data(100)

print("100 rows of data inserted successfully")

# Close the connection
cursor.close()
db.close()
