module ApplicationHelper

  def float_to_pence(float)
    (float.modulo(1).round(2) * 100).to_i
  end

end
