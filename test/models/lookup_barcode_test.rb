# frozen_string_literal: true

require 'test_helper'

class LookupBarcodeTest < ActiveSupport::TestCase
  test 'metadata object is returned with expected fields' do
    VCR.use_cassette('barcode 39080027236626') do
      metadata = LookupBarcode.new.info('39080027236626')

      expected_keys = %i[title date publisher authors link_resolver_url]

      expected_keys.each do |key|
        assert_includes(metadata.keys, key)
      end
    end
  end

  test 'link resolver URL returns a simple item URL' do
    VCR.use_cassette('barcode 39080027236626') do
      metadata = LookupBarcode.new.info('39080027236626')

      expected_url = 'https://mit.primo.exlibrisgroup.com/discovery/fulldisplay?vid=01MIT_INST:MIT&docid=alma990002933430106761'

      assert_equal(expected_url, metadata[:link_resolver_url])
    end
  end

  test 'barcode not found' do
    VCR.use_cassette('barcode not found') do
      metadata = LookupBarcode.new.info('this-is-not-a-barcode')

      assert_nil(metadata)
    end
  end
end
