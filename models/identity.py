from snowflake.snowpark.functions import lit, row_number
from snowflake.snowpark import Window

def model(dbt, session):
    # Step 1: Get the max ROW_NUMBER from PARSED_DATA
    result = session.sql(
        "SELECT MAX(ROW_NUMBER) AS LAST_ROW_NUMBER FROM MYDB.DBT_JSPARROW_PROD.PARSED_DATA"
    ).collect()
    
    last_row_number = result[0]["LAST_ROW_NUMBER"] or 0
    next_row_number = last_row_number + 1

    # Step 2: Load data from PARSED_BACKUP
    df_backup = session.table("MYDB.DBT_JSPARROW_PROD.PARSED_BACKUP")

    # Step 3: Add incremented ROW_NUMBER to each row
    window_spec = Window.order_by(lit(1))
    df_with_row_numbers = df_backup.with_column(
        "ROW_NUMBER",
        lit(next_row_number - 1) + row_number().over(window_spec)
    )

    # Step 4: Insert into PARSED_DATA
    df_with_row_numbers.write.insert_into(
        "MYDB.DBT_JSPARROW_PROD.PARSED_DATA", overwrite=False
    )

    # Step 5: Truncate PARSED_BACKUP
    session.sql("TRUNCATE TABLE MYDB.DBT_JSPARROW_PROD.PARSED_BACKUP").collect()

    # Step 6: Return the modified DataFrame (required by dbt)
    return df_with_row_numbers
