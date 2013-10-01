## TSB Project Linked Data

Rails app to provide access to information about TSB Projects as Linked Open Data.

### Getting started

* `bundle`
* Edit the environment config (e.g. development.rb) to point the endpoints to a running [Fuseki](https://jena.apache.org/documentation/serving_data/) instance.
* Download and install v0.90. [How?](http://www.elasticsearch.org/guide/reference/setup/).
* `rails server`

#### Running the data loader
`rake loader:complete_load` will :

* delete search index
* parse excel file and creates .nt dump,
* replace dataset data
* creates search index

See the other rake tasks for how to run these steps individually.