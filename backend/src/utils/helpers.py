from datetime import date, timedelta
import psycopg2
from flask import jsonify

from src.utils.constants import *
from src.utils.config import *
from src.utils.exceptions import *


def is_in_use(cursor, query, data_to_check):
    cursor.execute(query, (data_to_check,))
    return cursor.fetchone()[0] > 0


def check_email_and_password_from_user(email_from_user, password_from_user):
    if not email_from_user:
        raise MissingFieldsError({"email"})
    elif not password_from_user:
        raise MissingFieldsError({"password"})


def check_if_exists(cursor, table_to_check, column_to_check, data_to_check):
    if not does_exist(cursor, table_to_check, column_to_check, data_to_check):
        raise DataNotFoundError(table_to_check, column_to_check, data_to_check)


def does_exist(cursor, table_to_check, column_to_check, data_to_check):
    cursor.execute("SELECT COUNT(*) FROM {0} WHERE {1} = %s".format(table_to_check, column_to_check), (data_to_check,))
    exists = cursor.fetchone()[0]
    return exists


def does_exist_by_date(cursor, table_to_check, column1_to_check, data1_to_check, column2_to_check, data2_to_check):
    cursor.execute("SELECT COUNT(*) FROM {0} WHERE {1} = %s and {2} = %s"
                   .format(table_to_check, column1_to_check, column2_to_check), (data1_to_check, data2_to_check))
    exists = cursor.fetchone()[0]
    return exists


def add_dog_fitness(dog_id, fitness_column, fitness_new_data):
    db = load_database_config()
    today_date = date.today()

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                collar_id = get_collar_id_by_dog_id(cursor, dog_id)
                update_collar_connection(cursor, collar_id, CONNECTED_TO_MOBILE)

                if does_exist_by_date(cursor, FITNESS_TABLE, DOG_ID_COLUMN, dog_id, FITNESS_DATE_COLUMN, today_date):
                    update_dog_fitness(cursor, dog_id, fitness_column, fitness_new_data, today_date)
                else: # new day
                    create_dog_fitness(cursor, dog_id, fitness_column, fitness_new_data, today_date)

                connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST


def create_dog_fitness(cursor, dog_id, fitness_column, fitness_new_data, today_date):
    add_steps_query = f""" INSERT INTO {FITNESS_TABLE} 
                           ({DOG_ID_COLUMN}, {FITNESS_DATE_COLUMN}, {STEPS_COLUMN})
                           VALUES (%s, %s, %s); """

    add_distance_and_calories_query = f""" INSERT INTO {FITNESS_TABLE} ({DOG_ID_COLUMN}, {FITNESS_DATE_COLUMN}, 
                                           {DISTANCE_COLUMN}, {CALORIES_COLUMN})
                                           VALUES (%s, %s, %s, %s); """
    fitness_new_data = fix_data_before_create(cursor, dog_id, fitness_column, fitness_new_data)

    if fitness_column == DISTANCE_COLUMN:
        new_calories_burned = calculate_calories(cursor, dog_id, fitness_new_data)
        cursor.execute(add_distance_and_calories_query, (dog_id, today_date,
                                                         fitness_new_data, new_calories_burned))
    else:
        cursor.execute(add_steps_query, (dog_id, today_date, fitness_new_data))


def update_dog_fitness(cursor, dog_id, fitness_column, fitness_new_data, today_date):
    update_steps_query = f""" UPDATE {FITNESS_TABLE}
                              SET {STEPS_COLUMN} = %s
                              WHERE {DOG_ID_COLUMN} = %s AND {FITNESS_DATE_COLUMN} = %s; """

    update_distance_and_calories_query = f""" UPDATE {FITNESS_TABLE}
                                              SET {DISTANCE_COLUMN} = %s, {CALORIES_COLUMN} = %s
                                              WHERE {DOG_ID_COLUMN} = %s AND {FITNESS_DATE_COLUMN} = %s; """

    if fitness_column == DISTANCE_COLUMN:
        new_calories_burned = calculate_calories(cursor, dog_id, fitness_new_data)
        cursor.execute(update_distance_and_calories_query, (fitness_new_data, new_calories_burned,
                                                            dog_id, today_date))
    else:
        cursor.execute(update_steps_query, (fitness_new_data, dog_id, today_date))


def fix_data_before_create(cursor, dog_id, fitness_column, fitness_new_data):
    # Get last updated fitness data (yesterday)
    get_yesterday_fitness_query = f"""
                            SELECT {fitness_column}
                            FROM {FITNESS_TABLE} 
                            WHERE {DOG_ID_COLUMN} = %s AND {FITNESS_DATE_COLUMN} = %s;
                            """

    yesterday_date = date.today() - timedelta(days=1)
    cursor.execute(get_yesterday_fitness_query, (dog_id, yesterday_date))
    yesterday_fitness = cursor.fetchone()[0]

    if yesterday_fitness is None or yesterday_fitness <= fitness_new_data:
        fitness_new_data -= yesterday_fitness

    return fitness_new_data


def fix_data_before_update(cursor, dog_id, fitness_column, fitness_new_data):
    today_date = date.today()

    get_last_fitness_query = f""" SELECT {fitness_column}
                                  FROM {FITNESS_TABLE}
                                  WHERE {DOG_ID_COLUMN} = %s AND {FITNESS_DATE_COLUMN} = %s; """
    cursor.execute(get_last_fitness_query, (dog_id, today_date))


def update_battery_level(cursor, collar_id, new_level):
    update_battery_level_query = """
                                 UPDATE {0}
                                 SET battery_level = %s
                                 WHERE {1} = %s;
                                 """.format(COLLARS_TABLE, COLLAR_ID_COLUMN)
    cursor.execute(update_battery_level_query, (int(new_level), collar_id))


def get_dog_id_by_collar_id(cursor, collar_id):
    get_dog_id_query = "SELECT {0} FROM {1} WHERE {2} = %s;".format(DOG_ID_COLUMN, COLLARS_TABLE, COLLAR_ID_COLUMN)
    cursor.execute(get_dog_id_query, (collar_id,))
    dog_id = cursor.fetchone()

    if not dog_id:
        raise ValueError("There is no collar attached to this dog.")
    else:
        return dog_id[0]


def get_collar_id_by_dog_id(cursor, dog_id):
    get_collar_id_query = "SELECT {0} FROM {1} WHERE {2} = %s;".format(COLLAR_ID_COLUMN, COLLARS_TABLE, DOG_ID_COLUMN)
    cursor.execute(get_collar_id_query, (dog_id,))
    collar_id = cursor.fetchone()

    if not collar_id:
        raise ValueError("There is no collar attached to this dog.")
    else:
        return collar_id[0]


def get_dict_for_response(cursor):
    data_from_query = cursor.fetchone()
    columns_names = [desc[0] for desc in cursor.description]
    return dict(zip(columns_names, data_from_query))


def meters_to_kilometers(meters):
    return meters / 1000.0


def get_caloric_burn_rate(velocity):
    if velocity < 3:
        return 0.75  # Slow walk
    elif 3 <= velocity <= 6:
        return 1.0   # Moderate walk
    else:
        return 1.5   # Running


def calculate_calories(cursor, dog_id, distance):
    get_weight_query = """
                       SELECT weight
                       FROM {0}
                       WHERE {1} = dog_id;    
                       """.format(DOGS_TABLE, DOG_ID_COLUMN)

    cursor.execute(get_weight_query, (dog_id, ))
    weight = cursor.fetchone()[0]
    # burn_rate = get_caloric_burn_rate(velocity)
    burn_rate = 1.0 # Moderate walk (average)
    return weight * distance * burn_rate


def update_collar_connection(cursor, collar_id, is_connected_to_mobile):
    # If connected to mobile --> ble = True
    # else (connected to collar) --> wifi = True

    update_connection_query = """ UPDATE {0}
                                  SET wifi_connected = %s, ble_connected = %s
                                  WHERE collar_id = %s; """.format(COLLARS_TABLE)

    check_if_exists(cursor, COLLARS_TABLE, COLLAR_ID_COLUMN, collar_id)
    cursor.execute(update_connection_query, (not is_connected_to_mobile, is_connected_to_mobile, collar_id))


def check_collar_attachment(cursor, collar_id):
    get_attachment_status_query = f"SELECT {DOG_ID_COLUMN} FROM {COLLARS_TABLE} WHERE {COLLAR_ID_COLUMN} = %s;"
    cursor.execute(get_attachment_status_query, (collar_id,))
    dog_id = cursor.fetchone()[0]
    is_attached = dog_id is not None

    if is_attached:
        raise ValueError("Collar is attached to a dog already.")
