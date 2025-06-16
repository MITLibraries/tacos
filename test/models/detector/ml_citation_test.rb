# frozen_string_literal: true

require 'test_helper'

class Detector
  class MlCitationTest < ActiveSupport::TestCase
    # Ensure the expected_env? method returns false without everything set.
    test 'expected_env? returns true when all three env values are defined' do
      with_enabled_mlcitation do
        path = ENV.fetch('DETECTOR_LAMBDA_PATH', nil)
        secret = ENV.fetch('DETECTOR_LAMBDA_CHALLENGE_SECRET', nil)
        url = ENV.fetch('DETECTOR_LAMBDA_URL', nil)

        assert(path && secret && url)
        assert_predicate(Detector::MlCitation, :expected_env?)
      end
    end

    test 'expected_env? returns false without DETECTOR_LAMBDA_CHALLENGE_SECRET set' do
      with_enabled_mlcitation do
        assert_predicate(Detector::MlCitation, :expected_env?)
        ClimateControl.modify DETECTOR_LAMBDA_CHALLENGE_SECRET: nil do
          assert_equal false, Detector::MlCitation.expected_env?
        end
      end
    end

    test 'expected_env? returns false without DETECTOR_LAMBDA_PATH set' do
      with_enabled_mlcitation do
        assert_predicate(Detector::MlCitation, :expected_env?)
        ClimateControl.modify DETECTOR_LAMBDA_PATH: nil do
          assert_equal false, Detector::MlCitation.expected_env?
        end
      end
    end

    test 'expected_env? returns false without DETECTOR_LAMBDA_URL set' do
      with_enabled_mlcitation do
        assert_predicate(Detector::MlCitation, :expected_env?)
        ClimateControl.modify DETECTOR_LAMBDA_URL: nil do
          assert_equal false, Detector::MlCitation.expected_env?
        end
      end
    end

    # Class initalization
    test 'lookup returns false when a search is not a citation' do
      with_enabled_mlcitation do
        VCR.use_cassette('lambda no citation') do
          prediction = Detector::MlCitation.new('ping')

          assert_instance_of Detector::MlCitation, prediction

          assert_equal(false, prediction.detections)
        end
      end
    end

    test 'lookup returns true when a search is a citation' do
      with_enabled_mlcitation do
        VCR.use_cassette('lambda citation') do
          t = terms('citation')
          prediction = Detector::MlCitation.new(t.phrase)

          assert_instance_of Detector::MlCitation, prediction

          assert_equal(true, prediction.detections)
        end
      end
    end

    test 'non 200 http status responses result in no detection' do
      with_enabled_mlcitation do
        ClimateControl.modify DETECTOR_LAMBDA_CHALLENGE_SECRET: 'wrong secret' do
          VCR.use_cassette('lambda with wrong secret') do
            prediction = Detector::MlCitation.new('oops')

            assert_instance_of Detector::MlCitation, prediction

            assert_nil(prediction.detections)
          end
        end
      end
    end

    # Record method
    test 'record does relevant work' do
      with_enabled_mlcitation do
        VCR.use_cassette('lambda citation') do
          detection_count = Detection.count
          t = terms('citation')

          Detector::MlCitation.record(t)

          assert_equal(detection_count + 1, Detection.count)
        end
      end
    end

    test 'record does nothing when not needed' do
      with_enabled_mlcitation do
        skip 'Detector::MlCitation always gets true back from the lambda at the moment'
        detection_count = Detection.count
        t = terms('hi')

        Detector::MlCitation.record(t)

        assert_equal(detection_count, Detection.count)
      end
    end

    test 'record respects changes to the DETECTOR_VERSION value' do
      with_enabled_mlcitation do
        VCR.use_cassette('lambda citation sequence', allow_playback_repeats: true) do
          # Create a relevant detection
          Detector::MlCitation.record(terms('citation'))

          detection_count = Detection.count

          # Calling the record method again doesn't do anything, but does not error.
          Detector::MlCitation.record(terms('citation'))

          assert_equal(detection_count, Detection.count)

          # Calling the record method after DETECTOR_VERSION is incremented results in a new Detection
          ClimateControl.modify DETECTOR_VERSION: 'updated' do
            Detector::MlCitation.record(terms('citation'))

            assert_equal detection_count + 1, Detection.count
          end
        end
      end
    end
  end
end
