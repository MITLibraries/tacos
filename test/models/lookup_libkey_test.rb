# frozen_string_literal: true

require 'test_helper'

class LookupLibkeyTest < ActiveSupport::TestCase
  test 'metadata object is returned with expected fields for dois' do
    VCR.use_cassette('libkey doi 10.1038/d41586-023-03497-2') do
      metadata = LookupLibkey.info(doi: '10.1038/d41586-023-03497-2')

      expected_keys = %i[title authors doi pmid oa date journal_name journal_issns journal_image journal_link
                         link_resolver_url]

      expected_keys.each do |key|
        assert_includes(metadata.keys, key)
      end
    end
  end

  test 'metadata object is returned with expected fields for pmids' do
    VCR.use_cassette('libkey pmid 10490598') do
      metadata = LookupLibkey.info(pmid: '10490598')

      expected_keys = %i[title authors doi pmid oa date journal_name journal_issns journal_image journal_link
                         link_resolver_url]

      expected_keys.each do |key|
        assert_includes(metadata.keys, key)
      end
    end
  end

  test 'link resolver url returns expected value for dois' do
    VCR.use_cassette('libkey doi 10.1038/d41586-023-03497-2') do
      metadata = LookupLibkey.info(doi: '10.1038/d41586-023-03497-2')

      expected_url = 'https://libkey.io/libraries/FAKE_LIBKEY_ID/articles/594388926/full-text-file?utm_source=api_3735'

      assert_equal(expected_url, metadata[:link_resolver_url])
    end
  end

  test 'link resolver url returns expected value for pmids' do
    VCR.use_cassette('libkey pmid 10490598') do
      metadata = LookupLibkey.info(pmid: '10490598')

      expected_url = 'https://libkey.io/libraries/FAKE_LIBKEY_ID/articles/56753128/full-text-file?utm_source=api_3735'

      assert_equal(expected_url, metadata[:link_resolver_url])
    end
  end

  test 'doi or pmid are required' do
    error = assert_raises(ArgumentError) do
      LookupLibkey.info('no pmid or doi argument name given')
    end
    assert_equal 'wrong number of arguments (given 1, expected 0)', error.message
  end

  test 'LIBKEY_KEY is required' do
    ClimateControl.modify LIBKEY_KEY: nil do
      assert_nil(LookupLibkey.info(doi: '10.1038/d41586-023-03497-2'))
    end
  end

  test 'LIBKEY_ID is required' do
    ClimateControl.modify LIBKEY_ID: nil do
      assert_nil(LookupLibkey.info(doi: '10.1038/d41586-023-03497-2'))
    end
  end

  test 'blank doi and blank pmid returns nil' do
    metadata = LookupLibkey.info(doi: '')

    assert_nil(metadata)

    metadata = LookupLibkey.info(pmid: '')

    assert_nil(metadata)

    metadata = LookupLibkey.info(pmid: '', doi: '')

    assert_nil(metadata)
  end

  test 'contstruct url for doi' do
    expected_url = 'https://public-api.thirdiron.com/public/v1/libraries/FAKE_LIBKEY_ID/articles/doi/my_doi?include=journal&access_token=FAKE_LIBKEY_KEY'
    actual_url = LookupLibkey.construct_url(doi: 'my_doi')

    assert_equal(expected_url, actual_url)
  end

  test 'contstruct url for pmid' do
    expected_url = 'https://public-api.thirdiron.com/public/v1/libraries/FAKE_LIBKEY_ID/articles/pmid/my_pmid?include=journal&access_token=FAKE_LIBKEY_KEY'
    actual_url = LookupLibkey.construct_url(pmid: 'my_pmid')

    assert_equal(expected_url, actual_url)
  end

  test 'construct url with no pmid or do returns nil' do
    actual_url = LookupLibkey.construct_url

    assert_nil(actual_url)
  end

  test 'invalid doi lookup returns nil' do
    VCR.use_cassette('libkey doi nonsense') do
      metadata = LookupLibkey.info(doi: 'nonsense')

      assert_nil(metadata)
    end
  end

  test 'invalid pmid lookup returns nil' do
    VCR.use_cassette('libkey pmid nonsense') do
      metadata = LookupLibkey.info(pmid: 'nonsense')

      assert_nil(metadata)
    end
  end
end
