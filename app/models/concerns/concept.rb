module Concept

  extend ActiveSupport::Concern

  included do
    include Tripod::Resource

    class_attribute :resource_concept_scheme_uri

    field :in_scheme, RDF::SKOS.inScheme, :is_uri => true
    field :label, RDF::RDFS.label
    field :description, Vocabulary::DCTERMS.description

    field :sub_class_of, RDF::SKOS.subClassOf, :is_uri => true
    field :broader, RDF::SKOS.broader, :is_uri => true
    field :narrower, RDF::SKOS.narrower, :is_uri => true, :multivalued => true

    rdf_type RDF::SKOS.Concept

    def initialize(uri, graph_uri=nil)
      super
      self.in_scheme = self.class.resource_concept_scheme_uri
      self.sub_class_of = RDF::SKOS.Concept
    end
  end

  module ClassMethods

    def concept_scheme_uri(cs_uri)
      # set this resources concept scheme uri
      self.resource_concept_scheme_uri = cs_uri
      # derive the graph uri and set that.
      graph_uri cs_uri.to_s.gsub('/def/', '/graph/')
    end

  end

end