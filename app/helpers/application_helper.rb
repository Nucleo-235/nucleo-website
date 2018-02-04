module ApplicationHelper
  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end

  def level_name(level)
    return "FODA" if level >= 100
    return "BOM" if level >= 75
    return "OK" if level >= 50
    return "RUIM" if level >= 25
    return "FUDEU"
  end

  def index_formatted(index, value)
    number_to_currency(value, precision: index.value_precision, unit: index.value_prefix)
  end
end
