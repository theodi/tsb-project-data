namespace :loader do

  # e.g. INPUT_FILENAME='datatest1000.xlsx' rake loader:parse_excel
  desc 'reads excel file, and creates a data file'
  task prepare_project_data: :environment do
    input_filename = ENV['INPUT_FILENAME']
    Import::Loader.prepare_project_data(input_filename)
  end

  desc 'reads the excel files for the supporting data'
  task prepare_supporting_data: :environment do
    Import::Regions.create_data
    Import::Products.create_data
    Import::EnterpriseSizes.create_data
    Import::LegalEntityForms.create_data
    Import::ProjectStatuses.create_data
    Import::CostCategories.create_data
    Import::SicCodes.create_data
    Import::PriorityAreas.create_data
    Import::OntologyLoader.prepare_ontology
  end

  task enter_maintenance_mode: :environment do
    File.open(TsbProjectData::MAINTENANCE_FILE_PATH, "w") {}
  end

  task leave_maintenance_mode: :environment do
    Pathname.new(TsbProjectData::MAINTENANCE_FILE_PATH).delete
  end


  task load_new_data_if_available: :environment do
    puts '>>> checking remote file...'
    excel_download = ExcelDownload.new(TsbProjectData::REMOTE_EXCEL_FILE_LOCATION)

    if excel_download.is_new?
      puts '>>> modified!'
      puts '>>> downloading...'
      excel_download.download!
      Rake::Task['loader:complete_load'].invoke
    else
      puts '>>> not modified'
    end
  end

  # params:
  #  * INPUT_FILENAME: file to load
  #  * REPLACE_SUPPORTING: load supporting data? default false.
  # e.g.
  #  REPLACE_SUPPORTING=true INPUT_FILENAME='datatest1000.xlsx' rake loader:complete_load
  desc 'deletes search index, parses excel file, creates dump, loads dump into triple store, creates search index'
  task complete_load: :environment do

    begin

      input_filename = ENV['INPUT_FILENAME'] || 'TSB-data-public.xlsx'

      puts '>>> entering maintenance mode'
      Rake::Task['loader:enter_maintenance_mode'].invoke

      start_time = Time.now

      if ENV['REPLACE_SUPPORTING']
        puts '>>> preparing supporting data'
        Rake::Task['loader:prepare_supporting_data'].invoke
        puts '>>> replacing supporing data'
        Rake::Task['db:replace_supporting_data'].invoke
        puts ">>> clearing cache..."
        `echo 'flush_all' | nc localhost 11211`
        puts ">>> time elasped #{Time.now - start_time}s"
      end

      puts '>>> deleting search index...'
      Rake::Task['search:delete_index'].invoke
      puts ">>> time elasped #{Time.now - start_time}s"

      puts '>>> parsing excel'
      resources = Import::Loader.prepare_project_data(input_filename)
      puts ">>> time elasped #{Time.now - start_time}s"

      puts ">>> building search index..."
      search_index = Import::SearchIndex.new(resources)
      search_index.create
      search_index.build
      puts ">>> time elasped #{Time.now - start_time}s"

      puts ">>> loading ntriples dump to DB..."
      Rake::Task['db:replace_project_data'].invoke
      puts ">>> time elasped #{Time.now - start_time}s"

      puts ">>> updating dataset modified date and dump"
      ds = PublishMyData::Dataset.find("http://#{PublishMyData.local_domain}/data/#{TsbProjectData::DATASET_SLUG}")
      ds.modified = DateTime.now
      ds.data_dump = "http://#{PublishMyData.local_domain}/dumps/#{DataDump.latest.basename}"
      ds.save

      puts ">>> importing search index..."
      search_index.import
      search_index.refresh
      puts ">>> time elasped #{Time.now - start_time}s"

      puts ">>> clearing cache..."
      `echo 'flush_all' | nc localhost 11211`
      puts ">>> time elasped #{Time.now - start_time}s"

      puts ">>> generating data dump"
      Rake::Task['db:create_csv_dump'].invoke

      puts ">>> relinking dumps"
      `rm /home/rails/sites/tsb/current/public/dumps/*.*`
      `ln -nfs /home/rails/sites/tsb/shared/dumps/*.* /home/rails/sites/tsb/current/public/dumps/`

      puts ">>> clearing cache..."
      `echo 'flush_all' | nc localhost 11211`
      puts ">>> time elasped #{Time.now - start_time}s"

      # puts ">>> rendering static visualisations"
      # Rake::Task['viz:render_static'].invoke('tsb-projects.labs.theodi.org')

      puts ">>> time elasped #{Time.now - start_time}s"
      puts "FINISHED."

      Rake::Task['loader:leave_maintenance_mode'].invoke
    rescue Exception => e
      puts 'exception'
      if defined?(Raven)
        puts 'notifying raven'
        evt = Raven.capture_exception(e)
        Raven.send(evt) if evt
      end
    end

  end
end