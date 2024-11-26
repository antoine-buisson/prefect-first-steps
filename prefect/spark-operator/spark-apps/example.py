from pyspark.sql import SparkSession
import pandas as pd

def process(spark: SparkSession):
    
    ddf = spark.createDataFrame(pd.DataFrame({"test": [1, 2, 3]}))
    
    ddf_filtered = ddf.filter(ddf.test > 1)
    
    return ddf_filtered.toPandas()

if __name__ == "__main__":
    spark: SparkSession = SparkSession.builder.getOrCreate()
    
    spark.sparkContext.setLogLevel("INFO")
    
    df = process(spark)
    
    print(df)