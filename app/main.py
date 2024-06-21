import logging
import time
from faker import Faker

fake = Faker()


logging.basicConfig(
    filename='/var/log/my_app.log',
    level=logging.INFO,
    format='%(asctime)s - %(message)s',
)

def main():
    while True:
        logging.info(f"Hello, {fake.name()} from my Python application!")
        time.sleep(5)

if __name__ == "__main__":
    main()
