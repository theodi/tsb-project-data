atom_feed(schema_date: '2013-10-01') do |feed|
  feed.title("TSB Projects Open Data")
  feed.updated(DateTime.now)
  feed.author do |author|
    author.name("Technology Strategy Board")
  end
  @projects.each do |project|
    feed.entry(project, :url => project.uri) do |entry|
      entry.title(project.label)
      entry.content(
        RDiscount.new("
* Status: #{project.status_label}
* Grant amount: £#{number_with_delimiter(project.total_offer_grant)}
* Lead participant: #{project.leader_label}

#{project.description}
        ").to_html, type:'html')
      entry.updated(project.modified)
      entry.summary("Status: #{project.status_label}, Grant Amount: £#{number_with_delimiter(project.total_offer_grant)}")
    end
  end

end