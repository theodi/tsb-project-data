require 'spec_helper'

describe Project do

  describe '.csv_headers' do
    it "should return the right set of headers" do
      Project.csv_headers.should == ["project_id", "project_name", "start_date", "end_date", "cost_category", "project_status", "offer_grant", "offer_cost", "offer_percentage", "payments_to_date", "activity_code", "competition_code", "competition_year", "product", "budget_area", "org_id", "org_name", "company_number", "company_type", "company_size", "sic_codes", "isLead", "company_lat", "company_long", "region_id", "region", "district", "street", "town", "county", "postcode", "project_desc"]
    end
  end

  describe '.csv_data' do

    before do
      Tripod::SparqlClient::Query.should_receive(:select).at_least(:once).and_return(
        [
          # field 3 ommited
          {
            "field_1" => { "type" => "literal", "value" => "value_1" } ,
            "field_2" => { "type" => "uri", "value" => "value_2" }
          },
          {
            "field_1" => { "type" => "literal", "value" => "value_1" } ,
            "field_2" => { "type" => "uri", "value" => "value_2" } ,
            "field_3" => { "type" => "uri", "value" => "value_3" }
          }
        ]

      )

      Project.should_receive(:csv_headers).at_least(:once).and_return(
        ["field_1", "field_2", "field_3"]
      )

    end

    it "should return an array of data based on the result of the query" do
      Project.csv_data('http://blah').length.should == 2
      Project.csv_data('http://blah')
        .should == [
          ["value_1", "value_2", ""], ["value_1", "value_2", "value_3"]
        ]
    end

    it "should return empty blank cells if there's no data returned" do
      Project.csv_data('http://blah')[0][2].should == ""
    end
  end

end