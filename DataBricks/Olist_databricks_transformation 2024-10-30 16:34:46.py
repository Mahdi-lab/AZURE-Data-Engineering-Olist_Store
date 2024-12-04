# Databricks notebook source
from credentials import storage_account_name,container_name_silver,mount_name_silver,container_name,mount_name_bronze,storage_account_key

# COMMAND ----------

# Define your storage account, container, mount name, and access key
storage_account_name = storage_account_name
container_name = container_name
mount_name_bronze = mount_name_bronze
storage_account_key = storage_account_key

# Configure the access key in the configs dictionary for wasbs
configs = {
    f"fs.azure.account.key.{storage_account_name}.blob.core.windows.net": storage_account_key
}

# Check if storage is mounted
mount_point = f"/mnt/{mount_name_bronze}"
mounted = any(mount.mountPoint == mount_point for mount in dbutils.fs.mounts())

if mounted:
    print(f"Directory is already mounted at: {mount_point}")
else:
    print()
    # Mount the Azure Blob Storage container to Databricks using wasbs
    dbutils.fs.mount(
        source = f"wasbs://{container_name}@{storage_account_name}.blob.core.windows.net/",
        mount_point = f"/mnt/{mount_name_bronze}",
        extra_configs = configs
    )


# COMMAND ----------

# Define your storage account, container, mount name, and access key
storage_account_name_silver = mount_name_silver
container_name_silver = mount_name_silver
mount_name_silver = mount_name_silver
storage_account_key_silver = storage_account_key

# Check if storage is mounted
mount_point = f"/mnt/{mount_name_silver}"
mounted = any(mount.mountPoint == mount_point for mount in dbutils.fs.mounts())

if mounted:
    print(f"Directory is already mounted at: {mount_point}")
else:
    # Configure the access key in the configs dictionary for wasbs
    configs_silver = {
        f"fs.azure.account.key.{storage_account_name_silver}.blob.core.windows.net": storage_account_key_silver
    }

    # Mount the Azure Blob Storage container to Databricks using wasbs
    dbutils.fs.mount(
        source = f"wasbs://{container_name_silver}@{storage_account_name_silver}.blob.core.windows.net/",
        mount_point = f"/mnt/{mount_name_silver}",
        extra_configs = configs_silver
    )

# COMMAND ----------

# # display all contnents of bronzo dbo folder
# bronze_dbo_folders = dbutils.fs.ls("/mnt/bronze/dbo")
# display(bronze_dbo_folders)

# # display a parquet file
# customers_bronze_path = "/mnt/bronze/dbo/Dim_Customers"
# df_customers_parquet = spark.read.format("parquet").load(customers_bronze_path)
# df_customers_parquet.show(5)

# COMMAND ----------

from pyspark.sql.functions import col, date_format
from pyspark.sql.types import TimestampType

# Set Spark configurations for wasbs
spark.conf.set("fs.azure", "org.apache.hadoop.fs.azure.NativeAzureFileSystem")

# List all files in the folder
bronze_dbo_folders = dbutils.fs.ls("/mnt/bronze/dbo")

# Iterate through each folder and file
for folder in bronze_dbo_folders:
    for file in dbutils.fs.ls(folder.path):
        if file.path.endswith('.parquet'):
            # Create a view name from the file name
            view_name = file.path.split('/')[-1].replace(".parquet", "")
            file_path = file.path
            
            # Read the Parquet file into a DataFrame
            df = spark.read.parquet(file_path)
            
            # Get the columns of the DataFrame
            columns = df.columns
            
            # Check if the file is not "Dim_Date" (skip processing if it is)
            if view_name != "Dim_Date":
                # Loop through the columns and apply date formatting
                for column in columns:
                    # Check if the column name contains "date" or "Date"
                    if "date" in column.lower() and isinstance(df.schema[column].dataType, TimestampType):  # We use .lower() to handle both cases
                        # Format the date column to 'yyyyMMdd'
                        df = df.withColumn(column, date_format(col(column), 'yyyyMMdd'))
            
            # Create or replace the temporary view with the formatted DataFrame
            df.createOrReplaceTempView(view_name)

            # Save the DataFrame to Silver mount, overwriting any existing data
            silver_path_parquet = f"/mnt/silver/parquet/{view_name}"
            silver_path_delta = f"/mnt/silver/delta/{view_name}"
            # Write to Parquet format
            df.write.format("parquet").mode("overwrite").save(silver_path_parquet)

            # Write to Delta format (ensure the Delta Lake package is available)
            df.write.format("delta").mode("overwrite").save(silver_path_delta)

            print(f"Processed and saved '{view_name}' to {silver_path_parquet}.", " | " ,f"Processed and saved '{view_name}' to {silver_path_delta}.")


# COMMAND ----------

mount_points = ["/mnt/bronze", "/mnt/silver"]

for mount_point in mount_points:
    try:
        # Check if the mount point exists
        mounts = dbutils.fs.mounts()
        if any(mount.mountPoint == mount_point for mount in mounts):
            # If the mount exists, unmount it
            dbutils.fs.unmount(mount_point)
            print(f"Unmounted {mount_point}")
        else:
            # If the mount does not exist
            print(f"{mount_point} is unmounted")
    except Exception as e:
        print(f"Error checking mount for {mount_point}: {str(e)}")


# COMMAND ----------


