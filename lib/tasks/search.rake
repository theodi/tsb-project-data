namespace :search do

  desc 'deletes our index'
  task delete_index: :environment do
    Project.index.delete
  end

  # e.g. DEBUG=true LIMIT=20 rake search:import_projects
  desc 'imports all the exiting projects in the database into the index'
  task import_projects: :environment do
    limit = ENV['LIMIT']
    criteria = Project.all
    criteria = Project.all.limit(limit) if limit

    response = Project.index.import criteria.resources.to_a

    if response.success?
      Project.index.refresh
      body =  JSON.parse(response.body)
      puts "imported #{body['items'].length} items in #{body['took']}ms"
    else
      puts "fail"
      puts response
    end

    puts response if ENV['DEBUG']

  end

  # e.g. DEBUG=true LIMIT=20 rake search:reimport_projects
  desc 'imports all the exiting projects in the database into the index'
  task reimport_projects: :environment do
    Rake::Task['search:delete_index'].invoke
    Rake::Task['search:import_projects'].invoke
  end

end