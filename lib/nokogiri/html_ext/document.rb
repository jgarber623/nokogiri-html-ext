# frozen_string_literal: true

require 'nokogiri'

module Nokogiri
  module HTML4
    class Document < Nokogiri::XML::Document
      # A map of HTML `srcset` attributes and their associated element names.
      #
      # @see https://html.spec.whatwg.org/#srcset-attributes
      # @see https://html.spec.whatwg.org/#attributes-3
      IMAGE_CANDIDATE_STRINGS_ATTRIBUTES_MAP = {
        'imagesrcset' => %w[link],
        'srcset'      => %w[img source]
      }.freeze

      private_constant :IMAGE_CANDIDATE_STRINGS_ATTRIBUTES_MAP

      # A map of HTML URL attributes and their associated element names.
      #
      # @see https://html.spec.whatwg.org/#attributes-3
      URL_ATTRIBUTES_MAP = {
        'action'     => %w[form],
        'cite'       => %w[blockquote del ins q],
        'data'       => %w[object],
        'formaction' => %w[button input],
        'href'       => %w[a area base link],
        'ping'       => %w[a area],
        'poster'     => %w[video],
        'src'        => %w[audio embed iframe img input script source track video]
      }.freeze

      private_constant :URL_ATTRIBUTES_MAP

      # Get the <base> element's HREF attribute value.
      #
      # @return [String, nil]
      def base_href
        (base = at_xpath('//base[@href]')) && base['href'].strip
      end

      # Set the <base> element's HREF attribute value.
      #
      # If a <base> element exists, its HREF attribute value is replaced with
      # the given value. If no <base> element exists, this method will create
      # one and append it to the document's <head> (creating that element if
      # necessary).
      #
      # @param url [String, #to_s]
      #
      # @return [String]
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

      # Convert a relative URL to an absolute URL.
      #
      # @param url [String, #to_s]
      #
      # @return [String]
      def resolve_relative_url(url)
        unescape(
          uri_parser.join(*[document.url.strip, base_href, unescape(url)].compact.map { |u| escape(u) })
                    .normalize
                    .to_s
        )
      rescue URI::InvalidComponentError, URI::InvalidURIError
        unescape(url)
      end

      # Convert the document's relative URLs to absolute URLs.
      #
      # @return [self]
      #
      # rubocop:disable Style/PerlBackrefs
      def resolve_relative_urls!
        resolve_relative_urls_for(URL_ATTRIBUTES_MAP) { |value| resolve_relative_url(value.strip) }

        resolve_relative_urls_for(IMAGE_CANDIDATE_STRINGS_ATTRIBUTES_MAP) do |value|
          value
            .split(',')
            .map { |candidate| candidate.strip.sub(/^(.+?)(\s+.+)?$/) { "#{resolve_relative_url($1)}#{$2}" } }
            .join(', ')
        end

        self
      end
      # rubocop:enable Style/PerlBackrefs

      private

      def escape(url)
        uri_parser.escape(url.to_s)
      end

      def resolve_relative_urls_for(attributes_map)
        attributes_map.each do |attribute, names|
          xpaths = names.map { |name| "//#{name}[@#{attribute}]" }

          xpath(*xpaths).each do |node|
            node[attribute] = yield node[attribute]
          end
        end
      end

      def unescape(url)
        uri_parser.unescape(url.to_s)
      end

      def uri_parser
        @uri_parser ||= URI::DEFAULT_PARSER
      end
    end
  end
end
