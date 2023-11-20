# frozen_string_literal: true

require 'test_helper'

class LookupIssnTest < ActiveSupport::TestCase
  test 'metadata object is returned with expected fields' do
    VCR.use_cassette('issn 1078-8956') do
      metadata = LookupIssn.new.info('1078-8956')

      expected_keys = %i[publisher journal_issns journal_name link_resolver_url]
      expected_keys.each do |key|
        assert(metadata.keys.include?(key))
      end
    end
  end

  test 'link resolver url returns expected value' do
    VCR.use_cassette('issn 1078-8956') do
      metadata = LookupIssn.new.info('1078-8956')

      expected_url = 'https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/mit.tacos.api&vid=01MIT_INST:MIT&rft.issn=1078-8956'
      assert_equal(expected_url, metadata[:link_resolver_url])
    end
  end

  test 'non 200 responses' do
    VCR.use_cassette('issn not found') do
      metadata = LookupIssn.new.info('asdf')
      assert_nil(metadata)
    end
  end
end
