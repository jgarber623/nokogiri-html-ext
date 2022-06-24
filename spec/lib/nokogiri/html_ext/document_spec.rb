# frozen_string_literal: true

RSpec.describe 'Nokogiri::HTML4::Document' do
  describe '#base_href' do
    it 'returns nil when no base element found' do
      doc = Nokogiri::HTML('<html><body>hello, world</body></html>')

      expect(doc.base_href).to be_nil
    end

    it 'returns the HREF attibrute value when base element found' do
      doc = Nokogiri::HTML('<html><head><base href="https://example.com"></head></html>')

      expect(doc.base_href).to eq('https://example.com')
    end
  end

  describe '#base_href=' do
    it 'appends a base element when no base element found' do
      doc = Nokogiri::HTML('<html><body>hello, world</body></html>')

      doc.base_href = 'https://example.com'

      expect(doc.to_s).to match(%r{<base href="https://example.com">})
    end

    it 'sets the HREF attribute on a base element with no existing HREF attribute' do
      doc = Nokogiri::HTML('<html><head><base target="_top"></head><body>hello, world</body></html>')

      doc.base_href = 'https://example.com'

      expect(doc.to_s).to match(%r{<base target="_top" href="https://example.com">})
    end

    it 'sets the HREF attribute on a base element with an existing HREF attribute' do
      doc = Nokogiri::HTML('<html><head><base href="https://example.com"></head><body>hello, world</body></html>')

      doc.base_href = 'https://example.org'

      expect(doc.to_s).to match(%r{<base href="https://example.org">})
    end
  end
end
