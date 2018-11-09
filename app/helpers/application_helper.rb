module ApplicationHelper
  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end

  def get_level_idx(level, levels)
    level_step = (100/ (levels.length-1)).round
    level_idx = (level / level_step).floor
    return level_idx
  end

  def level_name(level)
    levels = ENV["LEVELS"].split(',')
    idx = get_level_idx(level, levels)
    return idx < levels.length ? levels[idx] : levels[levels.length-1]
  end

  def level_style(level)
    styles = ["#970401","#971C02","#973302","#983F02","#984A02","#986202","#997902","#999102","#8A9902","#7E9A02","#739A02","#5C9A02","#459B03"]
    idx = get_level_idx(level, styles)
    return "color: " + (idx < styles.length ? styles[idx] : styles[levels.length-1]) + ";"
  end

  def index_formatted(index, value)
    number_to_currency(value, precision: index.value_precision, unit: index.value_prefix)
  end
end
