class CsvDump

  attr_accessor :path

  def initialize(path)
    self.path = path
  end

  def modified
    File.mtime(path)
  end

  def basename
    File.basename(path)
  end

  # find the latest csv dump
  def self.latest
    # sort the csv files in reverse order, and pick the first one.
    path = Dir.glob( File.join(TsbProjectData::DUMP_OUTPUT_PATH, '*.csv') ).sort{ |a,b| b <=> a }.first

    CsvDump.new(path) if path
  end

end