## TSB Project Linked Data

Rails app to provide access to information about TSB Projects as Linked Open Data.

### Getting started

* `bundle`
* Edit development/test/production.rb to set config.sparql_endpoint to a running [Fuseki](https://jena.apache.org/documentation/serving_data/) instance.
* `rails server`

#### Running the data loader

* Create the data file to load with `rake db:create_data_file`
* Import it with 'rake db:replace_dataset_data`
* Create some dataset metadata with 'rake db:replace_dataset_metadata`