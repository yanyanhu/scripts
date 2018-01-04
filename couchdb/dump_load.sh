# Dump a database to file
curl -X GET http://localhost:5984/<DATABASE_NAME>/_all_docs?include_docs=true > FILE.txt

# Load data from file to database
curl -d @FILE.txt -H "Content-Type: application/json" -X POST http://localhost:5984/<DATABASE_NAME>/_bulk_docs

# Sometimes, the raw dump data file doesn't work for loading, need to use jq to format the data
curl -X GET 'http://localhost:5984/mydatabase/_all_docs?include_docs=true' | jq '{"docs": [.rows[].doc]}' | jq 'del(.docs[]._rev)' > db.json
