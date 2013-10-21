# reopen resource model, to redefine what are considered to be local resources
PublishMyData::Resource.class_eval do

  #TODO: allow this to be configured in PMD
  @@LOCAL_RESOURCES = [PublishMyData::Dataset, PublishMyData::ConceptScheme, PublishMyData::Ontology, Project, Organization]
  @@RESOURCES = [PublishMyData::ThirdParty::Ontology, PublishMyData::ThirdParty::ConceptScheme, PublishMyData::Concept, PublishMyData::OntologyClass, PublishMyData::Property, PublishMyData::RdfType, Region]

end
