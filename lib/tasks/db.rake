namespace :db do

  desc 'replace dataset metadata'
  task replace_dataset_metadata: :environment do
    puts url = "#{TsbProjectData::DATA_ENDPOINT}?graph=http://#{PublishMyData.local_domain}/graph/projects/metadata"
    puts payload = File.read(File.join(Rails.root, 'data', 'datasets', 'projects', 'metadata.ttl'))

    response = RestClient::Request.execute(
      :method => :put,
      :url => url,
      :payload => payload,
      :headers => {content_type: 'text/turtle'},
      :timeout => 300
    )
    puts response.inspect
  end

  desc 'replace dataset data'
  task replace_dataset_data: :environment do
    puts url = "#{TsbProjectData::DATA_ENDPOINT}?graph=http://#{PublishMyData.local_domain}/graph/projects"

    RestClient::Request.execute(
      :method => :put,
      :url => url,
      :payload => File.read(File.join(Rails.root, 'data', 'datasets', 'projects', 'data.nt')),
      :headers => {content_type: 'text/plain'},
      :timeout => 300
    )
  end

end