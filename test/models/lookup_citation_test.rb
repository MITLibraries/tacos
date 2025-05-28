# frozen_string_literal: true

require 'test_helper'

class LookupCitationTest < ActiveSupport::TestCase
  test 'DETECTOR_LAMBDA_CHALLENGE_SECRET is required' do
    ClimateControl.modify DETECTOR_LAMBDA_CHALLENGE_SECRET: nil do
      assert_nil(LookupCitation.new.info('ping'))
    end
  end

  test 'DETECTOR_LAMBDA_PATH is required' do
    ClimateControl.modify DETECTOR_LAMBDA_PATH: nil do
      assert_nil(LookupCitation.new.info('ping'))
    end
  end

  test 'DETECTOR_LAMBDA_URL is required' do
    ClimateControl.modify DETECTOR_LAMBDA_URL: nil do
      assert_nil(LookupCitation.new.info('ping'))
    end
  end

  test 'lookup returns true when lambda running' do
    # These cassettes should be regenerated once the lambda is running in AWS. For now it will need to be running
    # on localhost should the cassettes need to be regenerated.
    VCR.use_cassette('lambda running') do
      prediction = LookupCitation.new.info('ping')

      assert(prediction)
    end
  end

  test 'lookup returns nil when challenge_secret is wrong' do
    ClimateControl.modify DETECTOR_LAMBDA_CHALLENGE_SECRET: 'something wrong' do
      VCR.use_cassette('lambda with wrong secret') do
        prediction = LookupCitation.new.info('oops')

        assert_nil(prediction)
      end
    end
  end
end
