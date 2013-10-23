module Import
  module Regions

    def self.create_data
      regions = {
        "East Midlands" => "http://statistics.data.gov.uk/id/statistical-geography/E12000004",
        "West Midlands" => "http://statistics.data.gov.uk/id/statistical-geography/E12000005",
        "South West" => "http://statistics.data.gov.uk/id/statistical-geography/E12000009",
        "South East" => "http://statistics.data.gov.uk/id/statistical-geography/E12000008",
        "North West" => "http://statistics.data.gov.uk/id/statistical-geography/E12000002",
        "North East" => "http://statistics.data.gov.uk/id/statistical-geography/E12000001",
        "East of England" => "http://statistics.data.gov.uk/id/statistical-geography/E12000006",
        "Yorkshire and The Humber" => "http://statistics.data.gov.uk/id/statistical-geography/E12000003",
        "London" => "http://statistics.data.gov.uk/id/statistical-geography/E12000007",
        "Northern Ireland" => "http://statistics.data.gov.uk/id/statistical-geography/N92000002",
        "Scotland" => "http://statistics.data.gov.uk/id/statistical-geography/S92000003",
        "Wales" => "http://statistics.data.gov.uk/id/statistical-geography/W92000004"
      }

      output_file = File.join(TsbProjectData::DUMP_OUTPUT_PATH, 'regions.nt')

      graph = RDF::Graph.new

      regions.each_pair do |label,uri|
        r = Region.new(uri)
        r.label = label
        r.repository.each_statement {|s| graph << s}

      end

      # write graph to file
      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}

    end

  end
end