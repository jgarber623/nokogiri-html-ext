# frozen_string_literal: true

require 'nokogiri'

module Nokogiri
  module HTML4
    class Document < Nokogiri::XML::Document
      # Get the <base> element's HREF attribute value.
      #
      # @return [String, nil]
      def base_href
        (base = at_xpath('//base[@href]')) && base['href']
      end

      # Set the <base> element's HREF attribute value.
      #
      # If a <base> element exists, its HREF attribute value is replaced with
      # the given value. If no <base> element exists, this method will create
      # one and append it to the document's <head> (creating that element if
      # necessary).
      #
      # @param url [String, #to_s]
      def base_href=(url)
        url_str = url.to_s

        if (base = at_xpath('//base'))
          base['href'] = url_str
          url_str
        else
          base = XML::Node.new('base', self)
          base['href'] = url_str

          set_metadata_element(base)
        end
      end
    end
  end
end
