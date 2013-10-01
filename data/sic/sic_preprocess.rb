require 'roo'
require 'csv'
require 'json'

e = Roo::Excelx.new('sic2007summaryofstructur_tcm77-223506.xlsx')
output = File.open('sic.csv','w')
output_json = File.open('sic.json','w')
sic_hash = {}

for i in 4..e.last_row
  r = e.row(i).compact # gets row as array, then strip all nil values
  if r.first
    code = r.first
    if code.length > 4 # only include 'leaves' of tree in this list
      # strip out . and /
      code5 = code.gsub(/\./,'')
      code5 = code5.gsub(/\//,'')
      # add trailing zeroes up to 5 digits
      while code5.length < 5
        code5 = code5 + "0"
      end

 #     puts "#{code} #{code5}"
    
      description = r.last
      csv = [code5,description].to_csv
      sic_hash[description] = code5
      output << csv
    end
  end
  
  

  #puts row.first_column, row.last_column
end
output_json << sic_hash.to_json
output_json.close
output.close