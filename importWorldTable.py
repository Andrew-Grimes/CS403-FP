import pg8000
import pandas
import Connection 

df = pandas.read_csv("World-happiness-report-2024.csv")
connection = Connection.Connection().get_connection()
cursor = connection.cursor()

cursor.execute("""
    CREATE TABLE IF NOT EXISTS world_happiness (
        country_name TEXT,
        regional_indicator TEXT,
        ladder_score NUMERIC,
        upper_whisker NUMERIC,
        lower_whisker NUMERIC,
        logged_gdp_per_capita NUMERIC,
        social_support NUMERIC,
        healthy_life_expectancy NUMERIC,
        perception_of_corruption NUMERIC,
        dystopia_residual NUMERIC,
        positive_affect NUMERIC,
        negative_affect NUMERIC
    )
""")

print("table made")
df = df.where(pandas.notnull(df), None)
values = [tuple(row) for row in df.itertuples(index=False, name=None)]

insert_query = """
    INSERT INTO world_happiness (
        country_name,
        regional_indicator,
        ladder_score,
        upper_whisker,
        lower_whisker,
        logged_gdp_per_capita,
        social_support,
        healthy_life_expectancy,
        perception_of_corruption,
        dystopia_residual,
        positive_affect,
        negative_affect
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
"""

print("LOADING...")
cursor.executemany(insert_query, values)
print("DONE")

connection.commit()
cursor.close()
connection.close()

