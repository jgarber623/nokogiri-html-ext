# frozen_string_literal: true

require "nokogiri"

module Nokogiri
  module HTML4
    class Document < Nokogiri::XML::Document
      # A map of HTML +srcset+ attributes and their associated element names.
      #
      # @see https://html.spec.whatwg.org/#srcset-attributes
      # @see https://html.spec.whatwg.org/#attributes-3
      IMAGE_CANDIDATE_STRINGS_ATTRIBUTES_MAP = {
        "imagesrcset" => ["link"],
        "srcset"      => ["img", "source"]
      }.freeze

      private_constant :IMAGE_CANDIDATE_STRINGS_ATTRIBUTES_MAP

      # A map of HTML URL attributes and their associated element names.
      #
      # @see https://html.spec.whatwg.org/#attributes-3
      URL_ATTRIBUTES_MAP = {
        "action"     => ["form"],
        "cite"       => ["blockquote", "del", "ins", "q"],
        "data"       => ["object"],
        "formaction" => ["button", "input"],
        "href"       => ["a", "area", "base", "link"],
        "ping"       => ["a", "area"],
        "poster"     => ["video"],
        "src"        => ["audio", "embed", "iframe", "img", "input", "script", "source", "track", "video"]
      }.freeze

      private_constant :URL_ATTRIBUTES_MAP

      # Get the +<base>+ element's HREF attribute value.
      #
      # @return [String, nil]
      def base_href
        (base = at_xpath("//base[@href]")) && base["href"].strip
      end

      # Set the +<base>+ element's HREF attribute value.
      #
      # If a +<base>+ element exists, its HREF attribute value is replaced with
      # the given value. If no +<base>+ element exists, this method will create
      # one and append it to the document's +<head>+ (creating that element if
      # necessary).
      #
      # @param url [String, #to_s]
      #
      # @return [String]
      def base_href=(url)
        url_str = url.to_s

        if (base = at_xpath("//base"))
          base["href"] = url_str
          url_str
        else
          base = XML::Node.new("base", self)
          base["href"] = url_str

          set_metadata_element(base)
        end
      end

      # Convert a relative URL to an absolute URL.
      #
      # @param url [String, #to_s]
      #
      # @return [String]
      def resolve_relative_url(url)
        url_str = url.to_s

        # Escape each component before joining (Ruby's +URI.parse+ only likes
        # ASCII) and subsequently unescaping.
        uri_parser.unescape(
          uri_parser
            .join(*[doc_url_str, base_href, url_str].filter_map { |u| uri_parser.escape(u) unless u.nil? })
            .normalize
            .to_s
        )
      rescue URI::InvalidComponentError, URI::InvalidURIError
        url_str
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
            .split(",")
            .map { |candidate| candidate.strip.sub(/^(.+?)(\s+.+)?$/) { "#{resolve_relative_url($1)}#{$2}" } }
            .join(", ")
        end

        self
      end
      # rubocop:enable Style/PerlBackrefs

      private

      # +Nokogiri::HTML4::Document#url+ may be double-escaped if the parser
      # detects non-ASCII characters. For example, +https://[skull emoji].example+
      # is returned as +"https%3A//%25E2%2598%25A0%25EF%25B8%258F.example+.
      def doc_url_str
        @doc_url_str ||= uri_parser.unescape(uri_parser.unescape(document.url)).strip
      end

      def resolve_relative_urls_for(attributes_map)
        attributes_map.each do |attribute, names|
          xpaths = names.map { |name| "//#{name}[@#{attribute}]" }

          xpath(*xpaths).each do |node|
            node[attribute] = yield node[attribute]
          end
        end
      end

      def uri_parser
        @uri_parser ||= URI::DEFAULT_PARSER
      end
    end
  end
end
