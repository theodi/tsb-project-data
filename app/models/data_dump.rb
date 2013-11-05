class DataDump

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
    # sort the nt files in reverse order, and pick the first one.
    path = Dir.glob( File.join(TsbProjectData::DUMP_OUTPUT_PATH, 'project_data-*.nt') ).sort{ |a,b| b <=> a }.first

    DataDump.new(path) if path
  end

end