module RssHelper

  def valid_timestamp(datetime)
    datetime.strftime("%a, %d %b %Y %H:%M:%S ") + datetime.formatted_offset.gsub(/:/,'')
  end

end
