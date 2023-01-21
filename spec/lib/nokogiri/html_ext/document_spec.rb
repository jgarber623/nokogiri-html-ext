# frozen_string_literal: true

RSpec.describe 'Nokogiri::HTML4::Document' do
  subject(:doc) { Nokogiri::HTML5::Document.parse(markup, url) }

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

  describe '#resolve_relative_url' do
    let(:markup) { '<html><base href="/✨"></html>' }

    context 'when url is invalid' do
      it 'returns url' do
        expect(doc.resolve_relative_url('https:')).to eq('https:')
      end
    end

    context 'when url is absolute' do
      it 'returns url' do
        expect(doc.resolve_relative_url('https://aaronpk.example/home')).to eq('https://aaronpk.example/home')
      end
    end

    context 'when url is relative' do
      it 'resolves url' do
        expect(doc.resolve_relative_url('../../../home')).to eq('https://jgarber.example/home')
      end
    end

    context 'when path includes non-ASCII characters' do
      it 'resolves url' do
        expect(doc.resolve_relative_url('/👋🏻')).to eq('https://jgarber.example/👋🏻')
      end
    end
  end

  describe '#resolve_relative_urls!' do
    let(:markup) do
      <<~HTML.strip
        <html>
        <head>
          <base href="/foo/bar/biz">
        </head>
        <body>
          <a href="../../../..">Relative Root</a>
          <a href="/home">Home</a>
          <a href="/👋🏻">About</a>
          <a href="">Here</a>
          <img srcset="../foo.png 480w, ../bar.png 720w, /biz.jpg">
          <img src="/commons/thumb/9/96/H%C3%A5kon-Wium-Lie-2009-03.jpg/215px-H%C3%A5kon-Wium-Lie-2009-03.jpg">
          <a href="/foo%2epdf">Relative escaped PDF</a>
          <a href="mailto:email%40jgarber%2eexample">Valid escaped electronic mail</a>
          <a href="mailto:email_at_jgarber%2eexample">Invalid electronic mail</a>
        </body>
        </html>
      HTML
    end

    let(:markup_after) do
      <<~HTML.strip
        <html><head>
          <base href="https://jgarber.example/foo/bar/biz">
        </head>
        <body>
          <a href="https://jgarber.example/">Relative Root</a>
          <a href="https://jgarber.example/home">Home</a>
          <a href="https://jgarber.example/👋🏻">About</a>
          <a href="https://jgarber.example/foo/bar/biz">Here</a>
          <img srcset="https://jgarber.example/foo/foo.png 480w, https://jgarber.example/foo/bar.png 720w, https://jgarber.example/biz.jpg">
          <img src="https://jgarber.example/commons/thumb/9/96/H%C3%A5kon-Wium-Lie-2009-03.jpg/215px-H%C3%A5kon-Wium-Lie-2009-03.jpg">
          <a href="https://jgarber.example/foo%2epdf">Relative escaped PDF</a>
          <a href="mailto:email%40jgarber%2eexample">Valid escaped electronic mail</a>
          <a href="mailto:email_at_jgarber%2eexample">Invalid electronic mail</a>

        </body></html>
      HTML
    end

    before do
      doc.resolve_relative_urls!
    end

    its(:to_s) { is_expected.to eq(markup_after) }
  end
end
