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
  end

  # params:
  #  * INPUT_FILENAME: file to load
  #  * REPLACE_SUPPORTING: load supporting data? default false.
  # e.g.
  #  REPLACE_SUPPORTING=true INPUT_FILENAME='datatest1000.xlsx' rake loader:complete_load
  desc 'deletes search index, parses excel file, creates dump, loads dump into triple store, creates search index'
  task complete_load: :environment do

    input_filename = ENV['INPUT_FILENAME']

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

    puts ">>> importing search index..."
    search_index.import
    search_index.refresh
    puts ">>> time elasped #{Time.now - start_time}s"

    puts ">>> clearing cache..."
    `echo 'flush_all' | nc localhost 11211`
    puts ">>> time elasped #{Time.now - start_time}s"

  end
end