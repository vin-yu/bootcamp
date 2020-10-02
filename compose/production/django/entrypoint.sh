#!/bin/sh

set -o errexit
set -o pipefail
set -o nounset


cmd="$@"

mssql_ready() {
python << END

import sys
import pyodbc 

server = 'mssql' 
database = "${MSSQL_DB}"
username = "${MSSQL_ADMIN}"
password = "${SA_PASSWORD}"

try:
    cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = cnxn.cursor()
except pyodbc.Error as err:
    sys.exit(-1)
sys.exit(0)

END
}

until mssql_ready; do
  >&2 echo 'mssql is unavailable (sleeping)...'
  sleep 1
done

>&2 echo 'mssql is up - continuing...'

exec $cmd
