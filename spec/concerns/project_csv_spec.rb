require 'spec_helper'

describe Project do

  before do
   # `RAILS_ENV=test REPLACE_SUPPORTING=true INPUT_FILENAME='datatest10.xlsx' rake loader:complete_load `
  end

  describe 'csv_headers' do
    it "should return the right set of headers" do
      Project.csv_headers.should == ["project_id", "project_name", "start_date", "end_date", "cost_category", "project_status", "offer_grant", "offer_cost", "offer_percentage", "payments_to_date", "activity_code", "competition_code", "competition_year", "product", "budget_area", "org_id", "org_name", "company_number", "company_type", "company_size", "sic_code", "isLead", "company_lat", "company_long", "region_id", "region", "district", "street", "town", "county", "postcode", "project_desc"]
    end
  end

  describe 'csv_data' do
    it "should" do

    end
  end

end