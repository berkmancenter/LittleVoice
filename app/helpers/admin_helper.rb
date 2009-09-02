module AdminHelper

def rating_style(item, type)
  if @current_user.current_rating_type_for_item(item) == type
    "font-size:medium;font-weight:bold;"
  end
end

end
