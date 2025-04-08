# frozen_string_literal: true

require 'test_helper'

class Detector
  class SuggestedResourcePatternTest < ActiveSupport::TestCase
    test 'pattern matches return as expected' do
      match = SuggestedResourcePattern.new('astm standard thing and stuff')

      assert_predicate(match.detections, :present?)
    end

    test 'no patterns detected return as expected' do
      match = SuggestedResourcePattern.new('hello!')

      assert_not_predicate(match.detections, :present?)
    end

    test 'record does relevant work' do
      detection_count = Detection.count
      t = terms('astm')
      Detector::SuggestedResourcePattern.record(t)

      assert_equal(detection_count + 1, Detection.count)
    end

    test 'record does nothing when not needed' do
      detection_count = Detection.count
      t = terms('journal_nature_medicine')

      Detector::SuggestedResourcePattern.record(t)

      assert_equal(detection_count, Detection.count)
    end

    test 'record respects changes to the DETECTOR_VERSION value' do
      # Create a relevant detection
      t = terms('astm')
      Detector::SuggestedResourcePattern.record(t)

      detection_count = Detection.count

      # Calling the record method again doesn't do anything, but does not error.
      Detector::SuggestedResourcePattern.record(t)

      assert_equal(detection_count, Detection.count)

      # Calling the record method after DETECTOR_VERSION is incremented results in a new Detection
      ClimateControl.modify DETECTOR_VERSION: 'updated' do
        Detector::SuggestedResourcePattern.record(t)

        assert_equal detection_count + 1, Detection.count
      end
    end
  end
end
