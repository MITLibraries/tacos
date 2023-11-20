# frozen_string_literal: true

require 'test_helper'

class LookupIsbnTest < ActiveSupport::TestCase
  test 'metadata object is returned with expected fields' do
    VCR.use_cassette('isbn 978-0-08-102133-0') do
      metadata = LookupIsbn.new.info('978-0-08-102133-0')

      expected_keys = %i[title date publisher authors link_resolver_url]
      expected_keys.each do |key|
        assert(metadata.keys.include?(key))
      end
    end
  end

  test 'link resolver url returns expected value' do
    VCR.use_cassette('isbn 978-0-08-102133-0') do
      metadata = LookupIsbn.new.info('978-0-08-102133-0')

      expected_url = 'https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/mit.tacos.api&vid=01MIT_INST:MIT&rft.isbn=978-0-08-102133-0'
      assert_equal(expected_url, metadata[:link_resolver_url])
    end
  end

  test 'non 200 responses' do
    VCR.use_cassette('isbn not found') do
      metadata = LookupIsbn.new.info('asdf')
      assert_nil(metadata)
    end
  end
end
