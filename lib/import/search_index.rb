module Import
  class SearchIndex

    attr_accessor :resources
    attr_accessor :index_docs

    def initialize(resources)
      @resources = resources
      @index_docs = []
    end

    # builds up an array of index docs (and returns them)
    def build

      puts 'creating index docs'

      self.resources.each_pair do |uri, resource|
        if resource.is_a? Project
          puts resource.uri.to_s
          index_docs.push(resource.index_doc(resources))
        end
      end

      return index_docs
    end

    def import

      puts 'adding to elastic search...'
      response = Project.index.import index_docs

      body =  JSON.parse(response.body)
      puts "imported #{body['items'].length} items in #{body['took']}ms"

      puts "refreshing index"
      Project.index.refresh
    end

  end
end