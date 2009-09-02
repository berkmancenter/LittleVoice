module WhiteListHelper
  require 'RMagick'
  require 'base64'
  include Magick
  
  @@protocol_attributes = Set.new %w(src href)
  @@protocol_separator  = /:|(&#0*58)|(&#x70)|(%|&#37;)3A/
  mattr_reader :protocol_attributes, :protocol_separator
  
  def self.contains_bad_protocols?(white_listed_protocols, value)
    value =~ protocol_separator && !white_listed_protocols.include?(value.split(protocol_separator).first)
  end

  klass = class << self; self; end
  klass_methods = []
  inst_methods  = []
  [:bad_tags, :tags, :attributes, :protocols, :interstitial_attributes].each do |attr|
    # Add class methods to the module itself
    klass_methods << <<-EOS
      def #{attr}=(value) @@#{attr} = Set.new(value) end
      def #{attr}() @@#{attr} end
    EOS
    
    # prefix the instance methods with white_listed_*
    inst_methods << "def white_listed_#{attr}() ::WhiteListHelper.#{attr} end"
  end
  
  klass.class_eval klass_methods.join("\n"), __FILE__, __LINE__
  class_eval       inst_methods.join("\n"),  __FILE__, __LINE__

  # This White Listing helper will html encode all tags and strip all attributes that aren't specifically allowed.  
  # It also strips href/src tags with invalid protocols, like javascript: especially.  It does its best to counter any
  # tricks that hackers may use, like throwing in unicode/ascii/hex values to get past the javascript: filters.  Check out
  # the extensive test suite.
  #
  #   <%= white_list @article.body %>
  # 
  # You can add or remove tags/attributes if you want to customize it a bit.
  # 
  # Add table tags
  #   
  #   WhiteListHelper.tags.merge %w(table td th)
  # 
  # Remove tags
  #   
  #   WhiteListHelper.tags.delete 'div'
  # 
  # Change allowed attributes
  # 
  #   WhiteListHelper.attributes.merge %w(id class style)
  # 
  # white_list accepts a block for custom tag escaping.  Shown below is the default block that white_list uses if none is given.
  # The block is called for all bad tags, and every text node.  node is an instance of HTML::Node (either HTML::Tag or HTML::Text).  
  # bad is nil for text nodes inside good tags, or is the tag name of the bad tag.  
  # 
  #   <%= white_list(@article.body) { |node, bad| white_listed_bad_tags.include?(bad) ? nil : node.to_s.gsub(/</, '&lt;') } %>
  #
  def white_list(html, options = {}, &block)
    return html if html.blank? || !html.include?('<')
    attrs   = Set.new(options[:attributes]).merge(white_listed_attributes)
    tags    = Set.new(options[:tags]      ).merge(white_listed_tags)
    block ||= lambda { |node, bad| white_listed_bad_tags.include?(bad) ? insert_spaces(node.to_s) : node.to_s.gsub(/</, '&lt;').gsub(/>/, '&gt;') }
    returning [] do |new_text|
      tokenizer = HTML::Tokenizer.new(html)
      bad       = nil
      while token = tokenizer.next
        node = HTML::Node.parse(nil, 0, 0, token, false)
        new_text << case node
          when HTML::Tag
            node.attributes.keys.each do |attr_name|
              value = node.attributes[attr_name].to_s
              if !attrs.include?(attr_name) || (protocol_attributes.include?(attr_name) && contains_bad_protocols?(value))
                node.attributes.delete(attr_name)
              else
                if white_listed_interstitial_attributes.include?(attr_name) and not white_listed_bad_tags.include?(node.name)
                  node.attributes[attr_name] = insert_interstitial(value)
                  node.attributes["rel"] = "nofollow"
                else
                  node.attributes[attr_name] = CGI::escapeHTML(value)
                end
              end
            end if node.attributes
            if tags.include?(node.name)
              bad = nil
              node
            else
              bad = node.name
              block.call node, bad
            end
          else
            block.call node, bad
        end
      end
    end.join
  end
  
  protected
    def insert_interstitial(value)
      value = "/interstitial?uri=" + CGI::escape(value)
    end
    
    def convert_to_image(value)
      img = Image.read("caption:#{value}") do
        self.size = "600x"
        self.pointsize = 13
        self.font = "monospace"
        self.background_color = "transparent"
        self.antialias = true
      end
      data = Base64.b64encode(img[0].to_blob{|i| i.format = "PNG" })
      "<img src='data:image/png;base64,#{data}' alt='' />"
    end
    
    def insert_spaces(value)
      value.gsub /\<(\/)?[A-z]{2}/ do |match|
        match + "&nbsp;"
      end.gsub(/</, "&lt;").gsub(/>/, "&gt;")
    end
    
    def contains_bad_protocols?(value)
      WhiteListHelper.contains_bad_protocols?(white_listed_protocols, value)
    end
end

WhiteListHelper.interstitial_attributes = %w(href src)
WhiteListHelper.bad_tags   = %w(script iframe) 
WhiteListHelper.tags       = %w(a b i p em strong code pre sub sup acronym cite br div span h1 h2 h3 h4 h5 h6 ul ol li blockquote)
WhiteListHelper.attributes = %w(href cite datetime title src type width height)
WhiteListHelper.protocols  = %w(ed2k ftp http https irc mailto news gopher nntp telnet webcal xmpp callto feed)