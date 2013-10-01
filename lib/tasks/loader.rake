namespace :loader do
  desc 'reads excel file, and creates a data file'
  task parse_excel: :environment do
    Import::Loader.parse_excel_file
  end

  desc 'deletes search index, parses excel file, creates dump, loads dump into triple store, creates search index'
  task complete_load: :environment do
    start_time = Time.now

    puts '>>> deleting search index...'
    Rake::Task['search:delete_index'].invoke
    puts ">>> time elasped #{Time.now - start_time}s"

    puts '>>> parsing excel'
    resources = Import::Loader.parse_excel_file
    puts ">>> time elasped #{Time.now - start_time}s"

    puts ">>> building search index..."
    search_index = Import::SearchIndex.new(resources)
    search_index.build
    puts ">>> time elasped #{Time.now - start_time}s"

    puts ">>> loading ntriples dump to DB..."
    Rake::Task['db:replace_dataset_data'].invoke
    puts ">>> time elasped #{Time.now - start_time}s"

    puts ">>> importing search index..."
    search_index.import
    puts ">>> time elasped #{Time.now - start_time}s"

  end
end