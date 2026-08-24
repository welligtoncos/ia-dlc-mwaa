"""
Glue passthrough job — reads objects under raw/, writes Parquet under processed/dt=...
Compatible with Glue 4.0 (Spark).
"""
import sys
from datetime import datetime, timezone

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext

args = getResolvedOptions(
    sys.argv,
    ["JOB_NAME", "DATA_LAKE_BUCKET", "RAW_PREFIX", "PROCESSED_PREFIX"],
)

sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session
job = Job(glue_context)
job.init(args["JOB_NAME"], args)

bucket = args["DATA_LAKE_BUCKET"]
raw_prefix = args.get("RAW_PREFIX", "raw").rstrip("/")
processed_prefix = args.get("PROCESSED_PREFIX", "processed").rstrip("/")
dt = datetime.now(timezone.utc).strftime("%Y-%m-%d")

source_path = f"s3://{bucket}/{raw_prefix}/"
target_path = f"s3://{bucket}/{processed_prefix}/dt={dt}/"

dyf = glue_context.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": [source_path], "recurse": True},
    format="csv",
    format_options={"withHeader": True},
)

if dyf.count() == 0:
    spark.createDataFrame(
        [(dt, "glue_passthrough", "no_tabular_rows")],
        ["dt", "job", "note"],
    ).write.mode("overwrite").parquet(target_path)
else:
    dyf.toDF().write.mode("overwrite").parquet(target_path)

job.commit()
