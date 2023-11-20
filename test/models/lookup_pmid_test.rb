# frozen_string_literal: true

require 'test_helper'

class LookupPmidTest < ActiveSupport::TestCase
  test 'metadata object is returned with expected fields' do
    VCR.use_cassette('pmid 37953305') do
      metadata = LookupPmid.new.info('37953305')

      expected_keys = %i[title date journal_volume doi journal_name link_resolver_url]
      expected_keys.each do |key|
        assert(metadata.keys.include?(key))
      end
    end
  end

  test 'link resolver url returns expected value' do
    VCR.use_cassette('pmid 37953305') do
      metadata = LookupPmid.new.info('37953305')

      expected_url = "https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/mit.tacos.api&vid=01MIT_INST:MIT&rft.atitle=Flashy molecules decode a polymer's lengthening chain.&rft.date=2023&rft.jtitle=Nature&rft_id=info:doi/10.1038/d41586-023-03497-2"
      assert_equal(expected_url, metadata[:link_resolver_url])
    end
  end

  test 'non 200 responses' do
    VCR.use_cassette('pmid not found') do
      metadata = LookupPmid.new.info('asdf')
      assert_nil(metadata)
    end
  end
end
