require 'spec_helper'

describe ProjectsController do

  describe "#index" do
    let(:params) do
      {
        page: "2",
        per_page: "10",
        search_string: "laser",
        offer_grant_from: "50000",
        offer_grant_to: "390000",
      }
    end

    it "should create a Search with the action's params" do
      Search.should_receive(:new).at_least(:once).and_call_original
      get :index, params

      params.each_pair do |k,v|
        assigns[:search].params[k].should == v
      end
    end

    context "html format" do

      it "should also call search with no params" do
        get :index, params
        assigns[:search].should_not be_nil
        assigns[:search_unfiltered].should_not be_nil
        assigns[:search_unfiltered].params.should == {}
      end

    end

    context "csv format" do

      let(:csv_params) { params.merge(format: 'csv') }
      let(:csv_data) { [
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
      }

      before do
        # mock the csv data from db
        Tripod::SparqlClient::Query.should_receive(:select).at_least(:once).and_return(csv_data)

        # ...and elastic search results
        Search.any_instance.should_receive(:results).with(unpaginated:true).and_return(
          [Project.new('http://foo'), Project.new('http://bar'), Project.new('http://baz')]
        )

        get :index, csv_params.merge(format: 'csv')
      end

      it "should not call search_unfiltered" do
        assigns[:search].should_not be_nil
        assigns[:search_unfiltered].should be_nil
      end

      it "should return a row for every result in Project.csv_data" do
        assigns[:output_csv].split("\n").length.should == 7 # 1+ (3*2) (header, plus projects in results x no of rows per project)
      end

    end

  end

end