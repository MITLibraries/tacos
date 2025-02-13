# frozen_string_literal: true

require 'test_helper'

class InterventionControllerTest < ActionDispatch::IntegrationTest
  test 'doi intervention url is accessible without authentication' do
    VCR.use_cassette('doi 10.1038/d41586-023-03497-2') do
      get '/intervention/doi?doi=10.1038/d41586-023-03497-2'

      assert_response :success
    end
  end

  test 'doi intervention url returns error if no doi provided' do
    get '/intervention/doi'

    assert_response :not_found
  end

  test 'doi data returned from unpaywall' do
    VCR.use_cassette('doi 10.1038/d41586-023-03497-2') do
      get '/intervention/doi?doi=10.1038/d41586-023-03497-2'

      assert_not_nil @controller.instance_variable_get(:@json)
      assert_includes(@controller.instance_variable_get(:@json)[:link_resolver_url], 'mit.primo.exlibrisgroup.com')
      assert_not_includes(@controller.instance_variable_get(:@json)[:link_resolver_url], 'libkey.io')
    end
  end

  test 'doi data returned from libkey' do
    ClimateControl.modify LIBKEY_ID: 'FAKE_LIBKEY_ID', LIBKEY_KEY: 'FAKE_LIBKEY_KEY', LIBKEY_DOI: 'true' do
      VCR.use_cassette('libkey doi 10.1038/d41586-023-03497-2') do
        get '/intervention/doi?doi=10.1038/d41586-023-03497-2'

        assert_not_nil @controller.instance_variable_get(:@json)

        assert_includes(@controller.instance_variable_get(:@json)[:link_resolver_url], 'libkey.io')
        assert_not_includes(@controller.instance_variable_get(:@json)[:link_resolver_url], 'mit.primo.exlibrisgroup.com')
      end
    end
  end
end
