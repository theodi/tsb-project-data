## TSB Project Linked Data

Rails app to provide access to information about TSB Projects as Linked Open Data.

### Getting started

* `bundle`
* Edit the environment config (e.g. development.rb) to point the endpoints to a running [Fuseki](https://jena.apache.org/documentation/serving_data/) instance.
* `rails server`

#### Running the data loader

* Create the data file to load with `rake db:create_data_file` (creates a `data.nt` file in `data/datasets/tsb-projects-data`)
* Import it with `rake db:replace_dataset_data`
* Create some dataset metadata with `rake db:replace_dataset_metadata`

#### Elastic Search

Download and install v0.90. [How?](http://www.elasticsearch.org/guide/reference/setup/).

* Delete the index with `rake search:delete_index`
* Create index entries based on documents currently in the graph store with: `rake search:import_projects`
* You can check this has worked by running `Project.search("*")` from `rails console`.