namespace :loader do

  # e.g. INPUT_FILENAME='datatest1000.xlsx' rake loader:parse_excel
  desc 'reads excel file, and creates a data file'
  task parse_excel: :environment do
    input_filename = ENV['INPUT_FILENAME']
    Import::Loader.parse_excel_file(input_filename)
  end

  # e.g. INPUT_FILENAME='datatest1000.xlsx' rake loader:complete_load
  desc 'deletes search index, parses excel file, creates dump, loads dump into triple store, creates search index'
  task complete_load: :environment do

    input_filename = ENV['INPUT_FILENAME']
    start_time = Time.now

    puts '>>> deleting search index...'
    Rake::Task['search:delete_index'].invoke
    puts ">>> time elasped #{Time.now - start_time}s"

    puts '>>> parsing excel'
    resources = Import::Loader.parse_excel_file(input_filename)
    puts ">>> time elasped #{Time.now - start_time}s"

    puts ">>> building search index..."
    search_index = Import::SearchIndex.new(resources)
    search_index.create
    search_index.build
    puts ">>> time elasped #{Time.now - start_time}s"

    puts ">>> loading ntriples dump to DB..."
    Rake::Task['db:replace_dataset_data'].invoke
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