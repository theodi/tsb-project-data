class ProjectDuration
  include TsbResource

  rdf_type Vocabulary::TIMELINE.Interval
  
  field :start, Vocabulary::TIMELINE.start, datatype: RDF::XSD.date
  field :end, Vocabulary::TIMELINE.end, datatype: RDF::XSD.date
  
end