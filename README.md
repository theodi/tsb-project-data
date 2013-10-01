## TSB Project Linked Data

Rails app to provide access to information about TSB Projects as Linked Open Data.

### Getting started

* `bundle`
* Edit the environment config (e.g. development.rb) to point the endpoints to a running [Fuseki](https://jena.apache.org/documentation/serving_data/) instance.
* Download and install v0.90 of Elastic Search [How?](http://www.elasticsearch.org/guide/reference/setup/).
* `rails server`

#### Running the data loader
`REPLACE_SUPPORTING=true INPUT_FILENAME='datatest1000.xlsx' rake loader:complete_load`

This will:

* look for an excel file in the `/data/input-data` folder with the name in the `INPUT_FILENAME` env var
* replace the supporting data (if `REPLACE_SUPPORTING` is `true`)
* delete search index
* parse excel file and creates .nt dump,
* replace dataset data
* creates search index

See the other rake tasks for how to run these steps individually.