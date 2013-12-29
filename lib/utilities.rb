include WhiteListHelper
WhiteListHelper.tags = {}

class Utilities
  
  def self.white_list_custom(html, options = {}, &block)
    return html if html.blank? || !html.include?('<')
    attrs   = Set.new(options[:attributes]).merge(white_listed_attributes)
    tags    = Set.new(options[:tags]).merge(white_listed_tags)
    block ||= lambda { |node, bad| white_listed_bad_tags.include?(bad) ? nil : white_listed_tags.include?(bad)?(node):((node.class.to_s=="HTML::Tag")?(node.to_s.gsub(node.to_s, '')):(node)) }
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
                node.attributes[attr_name] = CGI::escapeHTML(value)
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

end