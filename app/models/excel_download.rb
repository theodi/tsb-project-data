class ExcelDownload

  attr_accessor :location

  def initialize(location)
    self.location = location
  end

  # was it modified after the last dump we made?
  def is_new?
    self.modified > CsvDump.latest.modified
  end

  def modified
    open(location) do |f|
      return f.last_modified
    end
  end

  def valid?
    true
  end

end