require 'roo'
require 'rdf'
require 'rdf/ntriples'
require './row2rdf.rb'

inputfile = 'datatest.xlsx'
outputfile = 'datatest.nt'

excel = Excelx.new(inputfile)

# take a copy of the header row for easy reference
headers = excel.row(1) 

graph = RDF::Graph.new

for i in 2..excel.last_row
  # make a hash of header names to cell contents for this row
  row = {}
  excel.row(i).each_with_index{|item,index| row[headers[index]] = item}
  row2rdf(graph,row)
  
end





# write out output
File.open(outputfile,'w') {|f| f << graph.dump(:ntriples)}