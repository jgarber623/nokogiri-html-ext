# nokogiri-html-ext

**A Ruby gem extending [Nokogiri](https://nokogiri.org) with several useful HTML-centric features.**

[![Gem](https://img.shields.io/gem/v/nokogiri-html-ext.svg?logo=rubygems&style=for-the-badge)](https://rubygems.org/gems/nokogiri-html-ext)
[![Downloads](https://img.shields.io/gem/dt/nokogiri-html-ext.svg?logo=rubygems&style=for-the-badge)](https://rubygems.org/gems/nokogiri-html-ext)
[![Build](https://img.shields.io/github/actions/workflow/status/jgarber623/nokogiri-html-ext/ci.yml?branch=main&logo=github&style=for-the-badge)](https://github.com/jgarber623/nokogiri-html-ext/actions/workflows/ci.yml)

## Key features

- Resolves all relative URLs in a Nokogiri-parsed HTML document.
- Adds helpers for getting and setting a document's `<base>` element's `href` attribute.
- Supports Ruby 2.7 and newer

## Getting Started

Before installing and using nokogiri-html-ext, you'll want to have [Ruby](https://www.ruby-lang.org) 2.7 (or newer) installed. Using a Ruby version managment tool like [rbenv](https://github.com/rbenv/rbenv), [chruby](https://github.com/postmodern/chruby), or [rvm](https://github.com/rvm/rvm) is recommended.

nokogiri-html-ext is developed using Ruby 2.7.8 and is tested against additional Ruby versions using [GitHub Actions](https://github.com/jgarber623/nokogiri-html-ext/actions).

## Installation

Add nokogiri-html-ext to your project's `Gemfile` and run `bundle install`:

```ruby
source "https://rubygems.org"

gem "nokogiri-html-ext"
```

## Usage

### `base_href`

nokogiri-html-ext provides two helper methods for getting and setting a document's `<base>` element's `href` attribute. The first, `base_href`, retrieves the element's `href` attribute value if it exists.

```ruby
require "nokogiri/html-ext"

doc = Nokogiri::HTML(%(<html><body>Hello, world!</body></html>))

doc.base_href
#=> nil

doc = Nokogiri::HTML(%(<html><head><base target="_top"><body>Hello, world!</body></html>))

doc.base_href
#=> nil

doc = Nokogiri::HTML(%(<html><head><base href="/foo"><body>Hello, world!</body></html>))

doc.base_href
#=> "/foo"
```

The `base_href=` method allows you to manipulate the document's `<base>` element.

```ruby
require "nokogiri/html-ext"

doc = Nokogiri::HTML(%(<html><body>Hello, world!</body></html>))

doc.base_href = "/foo"
#=> "/foo"

doc.at_css("base").to_s
#=> "<base href=\"/foo\">"

doc = Nokogiri::HTML(%(<html><head><base href="/foo"><body>Hello, world!</body></html>))

doc.base_href = "/bar"
#=> "/bar"

doc.at_css("base").to_s
#=> "<base href=\"/bar\">"
```

### `resolve_relative_urls!`

nokogiri-html-ext will resolve a document's relative URLs against a provided source URL. The source URL _should_ be an absolute URL (e.g. `https://jgarber.example`) representing the location of the document being parsed. The source URL _may_ be any `String` (or any Ruby object that responds to `#to_s`).

nokogiri-html-ext takes advantage of [the `Nokogiri::XML::Document.parse` method](https://github.com/sparklemotion/nokogiri/blob/main/lib/nokogiri/xml/document.rb#L48)'s second positional argument to set the parsed document's URL.Nokogiri's source code is _very_ complex, but in short: [the `Nokogiri::HTML` method](https://github.com/sparklemotion/nokogiri/blob/main/lib/nokogiri/html.rb#L7-L8) is an alias to [the `Nokogiri::HTML4` method](https://github.com/sparklemotion/nokogiri/blob/main/lib/nokogiri/html4.rb#L10-L12) which eventually winds its way to the aforementioned `Nokogiri::XML::Document.parse` method. _Phew._ 🥵

URL resolution uses Ruby's built-in URL parsing and normalizing capabilities. Absolute URLs will remain unmodified.

**Note:** If the document's markup includes a `<base>` element whose `href` attribute is an absolute URL, _that_ URL will take precedence when performing URL resolution.

An abbreviated example:

```ruby
require "nokogiri/html-ext"

markup = <<-HTML
  <html>
  <body>
    <a href="/home">Home</a>
    <img src="/foo.png" srcset="../bar.png 720w">
  </body>
  </html>
HTML

doc = Nokogiri::HTML(markup, "https://jgarber.example")

doc.url
#=> "https://jgarber.example"

doc.base_href
#=> nil

doc.base_href = "/foo/bar/biz"
#=> "/foo/bar/biz"

doc.resolve_relative_urls!

doc.at_css("base")["href"]
#=> "https://jgarber.example/foo/bar/biz"

doc.at_css("a")["href"]
#=> "https://jgarber.example/home"

doc.at_css("img").to_s
#=> "<img src=\"https://jgarber.example/foo.png\" srcset=\"https://jgarber.example/foo/bar.png 720w\">"
```

### `resolve_relative_url`

You may also resolve an arbitrary `String` representing a relative URL against the document's URL (or `<base>` element's `href` attribute value):

```ruby
doc = Nokogiri::HTML(%(<html><base href="/foo/bar"></html>), "https://jgarber.example")

doc.resolve_relative_url("biz/baz")
#=> "https://jgarber.example/foo/biz/baz"
```

## Acknowledgments

nokogiri-html-ext wouldn't exist without the [Nokogiri](https://nokogiri.org) project and its [community](https://github.com/sparklemotion/nokogiri).

nokogiri-html-ext is written and maintained by [Jason Garber](https://sixtwothree.org).

## License

nokogiri-html-ext is freely available under the MIT License. Use it, learn from it, fork it, improve it, change it, tailor it to your needs.
