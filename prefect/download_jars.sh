#!/bin/bash
set -e

# Ensure the output directory is provided as an argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <output-directory>"
  exit 1
fi

OUTPUT_DIR=$1

# Ensure the output directory exists or create it
if [ ! -d "${OUTPUT_DIR}" ]; then
  echo "Directory ${OUTPUT_DIR} does not exist. Creating it..."
  mkdir -p "${OUTPUT_DIR}"
fi

# Environment variables
export SCALA_VERSION=${SCALA_VERSION:-"2.12"}
export OPEN_LINEAGE_VERSION=${OPEN_LINEAGE_VERSION:-"1.24.2"}

declare -A JARS
JARS=(
  ["openlineage"]="https://repo1.maven.org/maven2/io/openlineage/openlineage-spark_${SCALA_VERSION}/${OPEN_LINEAGE_VERSION}/openlineage-spark_${SCALA_VERSION}-${OPEN_LINEAGE_VERSION}.jar"
)

echo "Downloading jars to ${OUTPUT_DIR}"

for jar in "${!JARS[@]}"; do
  echo "Downloading ${jar} jar... (${JARS[$jar]})"
  curl -L "${JARS[$jar]}" -o "${OUTPUT_DIR}/$(basename "${JARS[$jar]}")"
done

echo "All jars downloaded successfully to ${OUTPUT_DIR}."
