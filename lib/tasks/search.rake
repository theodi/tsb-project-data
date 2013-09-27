namespace :search do

  'deletes our index'
  task delete_index: :environment do
    Project.index.delete
  end

  'imports all the exiting projects in the database into the index'
  task import_projects: :environment do
    limit = ENV['LIMIT']
    criteria = Project.all
    criteria = Project.all.limit(limit) if limit

    response = Project.index.import criteria.resources.to_a

    if response.success?
      body =  JSON.parse(response.body)
      puts "imported #{body['items'].length} items in #{body['took']}ms"
    else
      puts "fail"
      puts response
    end

    puts response if ENV['DEBUG']

  end

end