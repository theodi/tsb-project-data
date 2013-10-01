module Import
  module Products

# create concept scheme for products
    def self.create_data

      input_file = File.join(Rails.root, 'data', 'input-data', 'data-definitions.xlsx')
      output_file = File.join(Rails.root, 'data', 'datasets', 'tsb-projects-data', 'products.nt')

      excel = Roo::Excelx.new(input_file)
      excel.default_sheet = "Reference Data"
      
      graph = RDF::Graph.new
      
      label2uri = {}
      
      for i in 2..excel.last_row

        if excel.cell(i,1) == "Product"
          code = excel.cell(i,2)
          label = excel.cell(i,3)
          definition = excel.cell(i,4)
                  
          p = Product.new(Vocabulary::TSBDEF["concept/product/#{code}"])
          p.label = label
          p.notation = code
          p.definition = definition
          label2uri[label] = p # store this for doing broader/narrower links
                            
        end
        
        
      end
      
      # deal with parent-child links
      for i in 2..excel.last_row
        if excel.cell(i,1) == "Product"
          label = excel.cell(i,3)
          p = label2uri[label]
          parent_label = excel.cell(i,5)
          parent = label2uri[parent_label] 
          if parent
            p.broader = parent.uri
            parent.narrower = parent.narrower.push(p.uri)
          end
            
        end
      end
      
      # output the data
      label2uri.each_value do |p|
        p.repository.each_statement {|s| graph << s}
      end
      
      
      # write graph to file
      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}
      
    end
    
    
    
  end
end