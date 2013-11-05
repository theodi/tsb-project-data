module ApplicationHelper

  def float_to_pence(float)
    (float.modulo(1).round(2) * 100).to_i
  end

  def project_participants_from_search_result(project)

    participant_uris = project.participant_uris
    participant_labels = project.participant_labels

    leader_index = project.participant_uris.index(project.leader_uri)

    # if the project has a leader, then move it to the start.
    if leader_index
      participant_uris.delete_at(leader_index)
      participant_uris.insert(0, project.leader_uri)

      participant_labels.delete_at(leader_index)
      participant_labels.insert(0, project.leader_label)
    end

    (0...participant_uris.length).collect do |i|
      link_to participant_labels[i], resource_path_from_uri(participant_uris[i])
    end.join(', ').html_safe
  end



  def csv_params(host=nil)
    p = remove_paging_params(params)
    p = p.merge(format: 'csv')
    p = p.merge(host: host) if host
    p
  end

end
