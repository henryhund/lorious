module ApplicationHelper
  def flash_class(level)
    case level
      when :notice then "info"
      when :error then "error"
      when :alert then "warning"
      else ""
    end
  end

  def placeholder_for_blank(data)
    return "-" if data.blank?
    data
  end

  def comma_seperated_string_to_array(string)
    string.split(",").map {|e| e.strip}
  end
end
