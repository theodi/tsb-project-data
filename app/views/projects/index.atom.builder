atom_feed(schema_date: '2013-10-01') do |feed|
  feed.tag!(:link, rel: "alternate", type: "text/csv", href: url_for(csv_params(request.host)))
  feed.title("TSB Projects Open Data")
  feed.updated(DateTime.now)
  feed.author do |author|
    author.name("Technology Strategy Board")
  end

  @projects.each do |project|
    feed.entry(project, :url => project.uri) do |entry|

      feed.tag!(:link, rel: "alternate", type: "application/json", href: "#{project.uri.gsub('/id/','/doc/')}.json" )
      feed.tag!(:link, rel: "alternate", type: "application/n-triples", href: "#{project.uri.gsub('/id/','/doc/')}.nt" )
      feed.tag!(:link, rel: "alternate", type: "text/turtle", href: "#{project.uri.gsub('/id/','/doc/')}.ttl" )
      feed.tag!(:link, rel: "alternate", type: "application/rdf+xml", href: "#{project.uri.gsub('/id/','/doc/')}.rdf" )

      entry.title(project.label)
      entry.content(
        RDiscount.new("
* Status: #{project.status_label}
* Grant amount: £#{number_with_delimiter(project.total_offer_grant)}
* Participants: #{project_participants_from_search_result(project)}

#{project.description}

[More information on this project](#{project.uri})
        ").to_html, type:'html')
      entry.updated(project.modified)
      entry.summary("Status: #{project.status_label}, Grant Amount: £#{number_with_delimiter(project.total_offer_grant)}")
    end
  end

end