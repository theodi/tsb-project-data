module ApplicationHelper

  def float_to_pence(float)
    (float.modulo(1).round(2) * 100).to_i
  end

  def project_participants_from_search_result(project)
    (0...project.participant_uris.length).collect { |i| link_to project.participant_labels[i], resource_path_from_uri(project.participant_uris[i]) }.join(', ').html_safe
  end

end
