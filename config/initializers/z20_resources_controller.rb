#re-open the resources controller to add more mappings
PublishMyData::ResourcesController.class_eval do
  private

  def template_for_resource(resource)
    {
      PublishMyData::Dataset       => 'publish_my_data/datasets/show',
      PublishMyData::Ontology      => 'publish_my_data/ontologies/show',
      PublishMyData::ConceptScheme => 'publish_my_data/concept_schemes/show',
      PublishMyData::OntologyClass => 'publish_my_data/classes/show',
      PublishMyData::Property      => 'publish_my_data/properties/show',
      PublishMyData::Concept       => 'publish_my_data/concepts/show',
      PublishMyData::Resource      => 'publish_my_data/resources/show',
      PublishMyData::ThirdParty::Ontology =>       'publish_my_data/ontologies/show',
      PublishMyData::ThirdParty::ConceptScheme =>  'publish_my_data/concept_schemes/show',

      # extras for this project
      # TODO: allow this to be configured in PMD?
      Project => 'projects/show',
      Organization => 'organizations/show',
      Region => 'regions/show'
    }[resource.class]
  end
end