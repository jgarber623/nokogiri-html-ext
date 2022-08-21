# frozen_string_literal: true

RSpec.describe 'Nokogiri::HTML4::Document' do
  subject(:doc) { Nokogiri::HTML(markup, url) }

  let(:url) { 'https://jgarber.example' }

  describe '#base_href' do
    context 'when no base element' do
      let(:markup) { '<html><body>hello, world</body></html>' }

      its(:base_href) { is_expected.to be_nil }
    end

    context 'when base element' do
      let(:markup) { '<html><head><base href="https://base.example"></head></html>' }

      its(:base_href) { is_expected.to eq('https://base.example') }
    end
  end

  describe '#base_href=' do
    context 'when no base element' do
      let(:markup) { '<html><body>hello, world</body></html>' }

      before do
        doc.base_href = 'https://base.example'
      end

      its(:to_s) { is_expected.to match(%r{<base href="https://base.example">}) }
    end

    context 'when base element with no HREF attribute' do
      let(:markup) { '<html><head><base target="_top"></head><body>hello, world</body></html>' }

      before do
        doc.base_href = 'https://base.example'
      end

      its(:to_s) { is_expected.to match(%r{<base target="_top" href="https://base.example">}) }
    end

    context 'when base element with HREF attribute' do
      let(:markup) { '<html><head><base href="https://example.com"></head><body>hello, world</body></html>' }

      before do
        doc.base_href = 'https://superbase.example'
      end

      its(:to_s) { is_expected.to match(%r{<base href="https://superbase.example">}) }
    end
  end

  describe '#resolve_relative_urls!' do
    let(:markup) do
      <<~HTML
        <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
        <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
          <base href="/foo/bar/biz">
        </head>
        <body>
          <a href="/home">Home</a>
          <img srcset="../foo.png 480w, ../bar.png 720w, /biz.jpg">
          <a href="mailto:email%40jgarber%2eexample">Valid escaped electronic mail</a>
          <a href="mailto:email_at_jgarber%2eexample">Invalid electronic mail</a>
        </body>
        </html>
      HTML
    end

    let(:markup_after) do
      <<~HTML
        <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
        <html>
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
          <base href="https://jgarber.example/foo/bar/biz">
        </head>
        <body>
          <a href="https://jgarber.example/home">Home</a>
          <img srcset="https://jgarber.example/foo/foo.png 480w, https://jgarber.example/foo/bar.png 720w, https://jgarber.example/biz.jpg">
          <a href="mailto:email@jgarber.example">Valid escaped electronic mail</a>
          <a href="mailto:email_at_jgarber.example">Invalid electronic mail</a>
        </body>
        </html>
      HTML
    end

    before do
      doc.resolve_relative_urls!
    end

    its(:to_s) { is_expected.to eq(markup_after) }
  end
end
