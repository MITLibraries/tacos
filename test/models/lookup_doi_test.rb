# frozen_string_literal: true

require 'test_helper'

class LookupDoiTest < ActiveSupport::TestCase
  test 'metadata object is returned with expected fields' do
    VCR.use_cassette('doi 10.1038/d41586-023-03497-2') do
      metadata = LookupDoi.new.info('10.1038/d41586-023-03497-2')

      expected_keys = %i[genre title date publisher oa oa_status best_oa_location journal_issns
                         journal_name link_resolver_url]

      expected_keys.each do |key|
        assert_includes(metadata.keys, key)
      end
    end
  end

  test 'link resolver url returns expected value' do
    VCR.use_cassette('doi 10.1038/d41586-023-03497-2') do
      metadata = LookupDoi.new.info('10.1038/d41586-023-03497-2')

      expected_url = 'https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/mit.tacos.api&vid=01MIT_INST:MIT&rft.atitle=Flashy molecules decode a polymer’s lengthening chain&rft.date=&rft.genre=journal-article&rft.jtitle=Nature&rft_id=info:doi/10.1038/d41586-023-03497-2'

      assert_equal(expected_url, metadata[:link_resolver_url])
    end
  end

  test 'non 200 responses' do
    VCR.use_cassette('doi not found') do
      metadata = LookupDoi.new.info('123456')

      assert_nil(metadata)
    end
  end
end
