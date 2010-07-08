module Redcloth
  if ActiveRecord::Base.connection.tables.include?("settings") and Setting.first
    Setting.find_or_create_by_namespace_and_key('FLICKR', 'API_KEY')
  end
  
  SWEARWORDS = [
    {:code=>/f[^a-zA-Z0-9]*[u*]+[^a-zA-Z0-9]*c[^a-zA-Z0-9]*k(er)?/,:replace=>"****"},
    {:code=>/sh[i1!]t(t?y)?/,:replace=>"****"},
    {:code=>/tits/,:replace=>"****"},
    {:code=>/motherfucker/,:replace=>"******"},
    {:code=>/bitch/,:replace=>"****"},
    {:code=>/cunt/,:replace=>"****"},
    {:code=>/asshole/,:replace=>"*******"},
    {:code=>/cocksucker/,:replace=>"****"},
    {:code=>/cock/,:replace=>"****"},
    {:code=>/n(!|\||\!|i|1|\*)gg((!|3|e|\*)(!|r|4)|a)/,:replace=>"African-American"},
    {:code=>/fag(got)?/,:replace=>"***"}
    ]
  
  class RedCloth::TextileDoc
    attr_accessor :embed_media
    attr_accessor :youtube
    attr_accessor :vimeo
    attr_accessor :white_list
    attr_accessor :flickr
    
    def embed_media=(boolean)
      @embed_media = boolean
      @youtube = boolean
      @vimeo = boolean
      @flickr = boolean if $FLICKR_API_KEY
    end
    
  end
  
  module RedCloth::Formatters::HTML
    include RedCloth::Formatters::Base
    require 'net/http' unless defined?(NET::HTTP)
    require 'URI' unless defined?(URI)
    require 'hpricot' unless defined?(Hpricot)
    
    
    
    def escape(text)
      for swear in SWEARWORDS
        text.gsub!(swear[:code],swear[:replace])
      end
      html_esc(text)
    end
    
    def after_transform(text)
      white_list ? text.replace(white_lister(text)) : text
      youtube ? text.replace(embed_youtube(text)) : text
      vimeo ? text.replace(embed_vimeo(text)) : text
      flickr ? text.replace(embed_flickr(text)) : text
    end
    
    protected
    
    def white_lister(text)
       ::ActionView::Base.new.white_list(text)
    end
    
    ###
    # Replaces instances of [youtube id|fmt] with embedded youtube videos
    def embed_youtube(text)
      text.gsub!( /\[youtube\s+(.*?)\]/i ) do
        video_id, format, image_only = $~[1].split('|').map!(&:strip)
        begin
          SBW::Timeout::timeout(4) do
            url = URI.parse("http://gdata.youtube.com/feeds/api/videos/#{video_id}")
            req = Net::HTTP::Get.new(url.path)
            @res = Net::HTTP.start(url.host, url.port) {|http|
              http.request(req)
            }
          end
          d = Hpricot.parse(@res.body)
          title = (d/"entry/title").first.inner_html
          image_url = (d/"media:thumbnail").map do |t|
            [t.get_attribute("height").to_i, t.get_attribute("url")]
          end.sort.last[1]
          width, height = get_dimensions(format)
          if image_only
            output = "<img src=\"#{image_url}\" alt='' height='#{height}' width='#{width}' />\n"
          else
            output = "<div class=\"embedded_video\"><div class=\"youtube\">
              <object width=\"#{width}\" height=\"#{height}\"><param name=\"movie\" value=\"http://www.youtube.com/v/#{video_id}&hl=en&fs=1&\"></param><param name=\"allowFullScreen\" value=\"true\"></param><param name=\"allowscriptaccess\" value=\"always\"></param><embed src=\"http://www.youtube.com/v/#{video_id}&hl=en&fs=1&\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" width=\"#{width}\" height=\"#{height}\"></embed></object>
            </div></div>\n"
          end
        rescue SBW::Timeout::Error
        rescue => e
        end
        output ||= "<div class=\"no_load\">[Video Error]</div>\n"
      end
      text
    end
    
    ###
    # Replaces instances of [vimeo id|fmt] with embedded vimeo videos
    def embed_vimeo(text)
      text.gsub!( /\[vimeo\s+(.*?)\]/i ) do
        video_id, format, image_only = $~[1].split('|').map!(&:strip)
        begin
          SBW::Timeout::timeout(4) do
            url = URI.parse("http://www.vimeo.com/api/v2/video/#{video_id}.xml")
            req = Net::HTTP::Get.new(url.path)
            @res = Net::HTTP.start(url.host, url.port) {|http|
              http.request(req)
            }
          end
          d = Hpricot.parse(@res.body)
          title = (d/"videos/video/title").first.inner_html
          image_url = (d/"videos/video/thumbnail_medium").first.inner_html
          width, height = get_dimensions(format)
          if image_only
            output = "<img src=\"#{image_url}\" alt='' height='#{height}' width='#{width}' />\n"
          else
            output = "<div class=\"embedded_video\"><div class=\"vimeo\">
              <object width=\"#{width}\" height=\"#{height}\"><param name=\"allowfullscreen\" value=\"true\" /><param name=\"allowscriptaccess\" value=\"always\" /><param name=\"movie\" value=\"http://vimeo.com/moogaloop.swf?clip_id=#{video_id}&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1\" /><embed src=\"http://vimeo.com/moogaloop.swf?clip_id=#{video_id}&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1\" type=\"application/x-shockwave-flash\" allowfullscreen=\"true\" allowscriptaccess=\"always\" width=\"#{width}\" height=\"#{height}\"></embed></object>
            </div></div>"
          end
        rescue SBW::Timeout::Error
        rescue => e
        end
        output ||= "<div class=\"no_load\">[Video Error]</div>\n"
      end
      text
    end
    
    def embed_flickr(text)
      text.gsub!( /\[flickr\s+(.*?)\]/i ) do 
        photo_id, format = $~[1].split('|').map!(&:strip)
        begin
          SBW::Timeout::timeout(4) do
            @res = Net::HTTP.get(URI.parse("http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=#{$FLICKR_API_KEY}&photo_id=#{photo_id}".toutf8))
          end
          d = Hpricot.parse(@res)
          farm_id = (d/"rsp/photo").attr('farm')
          server_id = (d/"rsp/photo").attr('server')
          secret = (d/"rsp/photo").attr('secret')
          photo_url = (d/"rsp/photo/urls/url").first.inner_html
          width, height = get_dimensions(format)
          photo_size = (width > 500 ? "_o" : "")
          url = "http://farm#{farm_id}.static.flickr.com/#{server_id}/#{photo_id}_#{secret}#{photo_size}.jpg"
          output = "<div class='embedded_photo'><div class='flickr'><img width='#{width}' src='#{url}' alt='#{photo_url}' /></div></div>"
        rescue SBW::Timeout::Error
        rescue => e
        end
        output ||= "<div class='no_load'>[Image Missing]</div>\n"
      end
      text
    end
    
    def get_dimensions(fmt = nil)
      case fmt
        when "22"
          width = 720
          height = 405
        when "18"
          width = 480
          height = 320
        when "6"
          width = 480
          height = 320
        else
          if /(\d+)\,(\d+)/ =~ fmt
            width = $~[1].to_i
            height = $~[2].to_i
          else
            width = 380
            height = 285
          end
      end
      return [width, height]
    end
    
  end
end
