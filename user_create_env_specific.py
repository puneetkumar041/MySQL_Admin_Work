import random
import string
from mysql.connector import connect, Error

# Function to read credentials from a file
def read_credentials(file_path):
    credentials = {}
    try:
        with open(file_path, 'r') as file:
            for line in file:
                key, value = line.strip().split('=')
                credentials[key] = value
        return credentials
    except FileNotFoundError:
        print(f"Error: File {file_path} not found.")
        exit()
    except ValueError:
        print(f"Error: Invalid format in {file_path}. Ensure each line is in 'key=value' format.")
        exit()

# Load credentials
credentials = read_credentials("credentials.txt")

DB_HOST = credentials.get("DB_HOST")
DB_USER = credentials.get("DB_USER")
DB_PASSWORD = credentials.get("DB_PASSWORD")
DB_PROD = credentials.get("DB_PROD")
DB_PREPROD = credentials.get("DB_PREPROD")

def connect_to_mysql():
    try:
        connection = connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD
        )
        if connection.is_connected():
            return connection
    except Error as e:
        print(f"Error: {e}")
        return None

def generate_random_password(length=12):
    if length < 4:
        raise ValueError("Password length must be at least 4 to meet the condition requirements.")
    
    # Define the categories for the password
    lowercase = random.choice(string.ascii_lowercase)
    uppercase = random.choice(string.ascii_uppercase)
    numeric = random.choice(string.digits)
    non_alphanumeric = random.choice(string.punctuation)

    # Generate the remaining characters
    remaining_length = length - 4
    remaining_chars = random.choices(string.ascii_letters + string.digits + string.punctuation, k=remaining_length)

    # Combine all parts and shuffle to ensure randomness
    password_list = [lowercase, uppercase, numeric, non_alphanumeric] + remaining_chars
    random.shuffle(password_list)

    # Join the list into a single string and return
    return ''.join(password_list)

def write_to_file(username, password, environment):
    # Define the file path
    file_path = 'generated_password.txt'

    # Remove existing file (if any)
    try:
        with open(file_path, 'w') as file:
            file.write(f"Username: {username}\n")
            file.write(f"Password: {password}\n")
            file.write(f"Environment: {environment}\n")
        print(f"Details saved in {file_path}")
    except Exception as e:
        print(f"Error writing to file: {e}")

def create_user_from_email(email, environment, role):
    try:
        connection = connect_to_mysql()
        if not connection:
            print("Failed to connect to the database.")
            return

        cursor = connection.cursor()

        # Extract username from email
        username = email.split('@')[0]

        # Generate a secure random password
        password = generate_random_password(12)

        # Determine access level
        if role == "dba":
            if environment == "prod":
                privileges = "ALL PRIVILEGES"
                database = DB_PROD
            elif environment == "preprod":
                privileges = "ALL PRIVILEGES"
                database = DB_PREPROD
            else:
                print("Invalid environment specified.")
                return
        elif role in ["dev", "qa"]:
            if environment == "prod":
                privileges = "SELECT"
                database = DB_PROD
            elif environment == "preprod":
                privileges = "ALL PRIVILEGES"
                database = DB_PREPROD
            else:
                print("Invalid environment specified.")
                return
        else:
            print("Invalid role specified.")
            return

        # Create user and assign privileges
        cursor.execute(f"CREATE USER '{username}'@'%' IDENTIFIED BY '{password}';")
        cursor.execute(f"GRANT {privileges} ON {database}.* TO '{username}'@'%';")
        connection.commit()
        print(f"User '{username}' created with {privileges} access on {database}.")

        # Save the details to a text file
        write_to_file(username, password, environment)

    except Error as e:
        print(f"Error: {e}")
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

if __name__ == "__main__":
    print("User Creation Utility")
    email = input("Enter the email ID: ").strip()
    environment = input("Enter the environment (prod/preprod): ").strip().lower()
    role = input("Enter the role (dev/qa/dba): ").strip().lower()

    create_user_from_email(email, environment, role)

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

cd path/to/your/script

python3 user_creation.py

User Creation Utility
Enter the email ID: example@domain.com
Enter the environment (prod/preprod): prod
Enter the role (dev/qa/dba): dba
User 'example' created with ALL PRIVILEGES access on production_db.
Details saved in generated_password.txt
