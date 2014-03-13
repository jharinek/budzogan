module LinkHelper
  def icon_link_to(type, body, url = nil, options = {})
    link_to icon_tag(type, label: body, fixed: options.delete(:fixed), join: options.delete(:join)), url, options
  end
end