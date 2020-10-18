#!/usr/bin/env python3

import psycopg2
import os
import logging
import time

logger = logging.getLogger("postgres-ping")

state = 1
while state > 0:
    try:
        connection = psycopg2.connect(
            dbname=os.environ.get('SQL_DATABASE'),
            user=os.environ.get('SQL_USER'),
            password=os.environ.get('SQL_PASSWORD'),
            host=os.environ.get('SQL_HOST'),
            port=5432)
        state = connection.closed
        print("**** Database is ready! ****")
        logger.info("Database is ready!")
    except Exception as connection_exception:
        logger.error(connection_exception)
        time.sleep(1)
        pass