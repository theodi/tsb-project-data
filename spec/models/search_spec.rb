require 'spec_helper'

describe Search do

  let(:params) do

    HashWithIndifferentAccess.new(
      {
        "search_string" => "laser",
        "offer_grant_from" => "50000",
        "offer_grant_to" => "390000",
        "date_from" => "2006-12-01",
        "date_to" => "2015-01-01",
        "region_labels" => {"Yorkshire and The Humber" => "true"},
        "participant_size_labels" => {"micro" => "true", "small" => "true"}
      }
    )
  end

  let(:search) { Search.new(params) }
  let(:blank_search) { Search.new }

  it "should store the original params passed to the constructor" do
    search.params.should == params
  end

  describe "process_sorting_params" do
    it "should default to sorting by _score, desc" do
      blank_search.sort_by.should == "_score"
      blank_search.sort_order.should == "desc"
    end

    context "the sorting parameters passed in our allowed values" do
      it "should use the sorting parameters passed to the ctor" do
        s = Search.new( sort_by: "start_date", sort_order: "asc")
        s.sort_by.should == "start_date"
        s.sort_order.should == "asc"
      end
    end

    context "the sorting parameters are not in our allowed values" do
      it "should sort by _score, desc" do
        s = Search.new( sort_by: "foo", sort_order: "bar")
        s.sort_by.should == "_score"
        s.sort_order.should == "desc"
      end
    end
  end

  describe "process_pagination_params" do

    it "should default to page 1 and 10 per page" do
      blank_search.page.should == 1
      blank_search.per_page.should == 10
    end

    context "per_page is more than 100" do
      it "should max out at 100" do
        s = Search.new( per_page: 200 )
        s.per_page.should == 100
      end
    end

    it "should use the per_page and page parameters passed to the ctor" do
      s = Search.new( per_page: 99, page: 3)
      s.per_page.should == 99
      s.page.should == 3
    end

  end

  describe "process_search_string" do

    it "should remember the original search string" do
      search.original_search_string.should == params["search_string"]
      search.search_string.should == params["search_string"]
    end

    context "when the search string is empty" do
      it "should default to '*'" do
        blank_search.original_search_string.should be_nil
        blank_search.search_string.should == "*"
      end
    end

  end

  describe 'process_facets' do
    it "should set the values from the params into our facets hash" do
      search.facets['region_labels'].should == ["Yorkshire and The Humber"]
      search.facets['participant_size_labels'].should == ["micro", "small"]
    end
  end

  describe 'process_date_range' do
    context "date from and to params unspecified" do
      it "should default the date_from and date_to to nil" do
        blank_search.date_from.should be_nil
        blank_search.date_to.should be_nil
      end

      it "should not set a date_range_filter" do
        blank_search.date_range_filter.should be_nil
      end
    end

    it "should set the date_from and date_to to the values in the params (as Dates)" do
      search.date_from.should == DateTime.parse(search.params[:date_from])
      search.date_to.should == DateTime.parse(search.params[:date_to])
    end

    it "should set a date_range_filter with a Tire search filter (based on the from and to dates)" do
      search.date_range_filter.to_hash.should == {
        :and => [
          {:range=>{:end_date => {:gte=>"Fri, 01 Dec 2006 00:00:00 +0000"}}},
          {:range=>{:start_date=>{:lte=>"Thu, 01 Jan 2015 00:00:00 +0000"}}}
        ]
      }
    end

  end

  describe 'process_grant_range' do

    context "offer grant from and to params unspecified" do

      it "should default the offer_grant_from and offer_grant_to to nil" do
        blank_search.offer_grant_from.should be_nil
        blank_search.offer_grant_to.should be_nil
      end

      it "should not set a grant_range_filter" do
        blank_search.grant_range_filter.should be_nil
      end
    end

    it "should set the offer_grant_from and offer_grant_to to the values in the params (as integers)" do
      search.offer_grant_from.should == search.params[:offer_grant_from].to_i
      search.offer_grant_to.should == search.params[:offer_grant_to].to_i
    end

    it "should set grant_range_filter with a Tire search filter (based on the from and to grants)" do
      search.grant_range_filter.to_hash.should == {
        :range =>
        {
          :total_offer_grant =>
          {
            :gte => search.offer_grant_from,
            :lte => search.offer_grant_to
          }
        }
      }
    end
  end

  describe 'get_range_filters' do
    it "should return an array of the filters" do
      search.send(:get_range_filters).should == [search.grant_range_filter, search.date_range_filter]
      blank_search.send(:get_range_filters).should == []
    end
  end

  describe "get_filter_for_other_fields" do
    it "should return a new Tire::Search::Filter with the filters for all the other facets" do
      search.send(:get_filter_for_other_facets, 'participant_size_labels')
        .should == {
            :and=>[
              {:terms=>{"region_labels"=>["Yorkshire and The Humber"]}}
            ]
        }
    end
  end

  describe "get_range_filters" do
    it "should return an array of the range filters" do
      rf = search.send(:get_range_filters)
      rf.length.should == 2
      rf.should == [
        # the grant range
        {:range=>{:total_offer_grant=>{:gte=>50000, :lte=>390000}}},

        # the date ranges
        {
          :and=>[
            {:range=>{:end_date=>{:gte=>"Fri, 01 Dec 2006 00:00:00 +0000"}}},
            {:range=>{:start_date=>{:lte=>"Thu, 01 Jan 2015 00:00:00 +0000"}}}
          ]
        }
      ]
    end
  end

  describe "get_facet_filters" do
    it "should return an array of facet filters which includes the other facet filters, plus the AND-ed range filters" do
      ff = search.send(:get_facet_filters, 'participant_size_labels')
      ff.length.should == 2
      ff.should == [
        {
          # the other facet filters
          :and=>[
            {:terms=>{"region_labels"=>["Yorkshire and The Humber"]}}
          ]
        },
        {
          # the range filters AND-ed together
          :and=>[
            {:range=>{:total_offer_grant=>{:gte=>50000, :lte=>390000}}},
            {
              :and=>[
                {:range=>{:end_date=>{:gte=>"Fri, 01 Dec 2006 00:00:00 +0000"}}},
                {:range=>{:start_date=>{:lte=>"Thu, 01 Jan 2015 00:00:00 +0000"}}}
              ]
            }
          ]
        }
      ]
    end
  end

end

