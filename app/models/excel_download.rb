class ExcelDownload

  attr_accessor :location

  def initialize(location)
    self.location = location
  end

  def is_new?
    # either we've got no latest csv dump, or this file was modified since our latest csv.
    (!CsvDump.latest) || self.modified > CsvDump.latest.modified
  end

  def modified
    open(location) do |f|
      return f.last_modified
    end
  end

  # downloads the file to the input data folder.
  def download!
    `wget #{self.location} -O #{File.join(Rails.root, 'data', 'input-data', 'TSB-data-public.xlsx')}`
  end

  def valid?
    true
  end

end