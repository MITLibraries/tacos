# frozen_string_literal: true

require 'test_helper'

class Detector
  class CitationTest < ActiveSupport::TestCase
    test 'detector::citation exposes four instance variables' do
      t = terms('citation')
      result = Detector::Citation.new(t.phrase)

      assert_predicate result.features, :present?

      assert_predicate result.score, :present?

      assert_predicate result.summary, :present?

      assert_predicate result.patterns, :present?
    end

    test 'citation score increases as phrase gets more citation-like' do
      result = Detector::Citation.new('simple search phrase')

      assert_equal 0, result.score

      result = Detector::Citation.new('Science Education and Cultural Diversity: Mapping the Field. Studies in Science Education, 24(1), 49–73.')

      assert_operator 0, :<, result.score
    end

    test 'detection? convenience method returns true for obvious citations' do
      result = Detector::Citation.new(terms('citation').phrase)

      assert_predicate result, :detection?
    end

    test 'detection? convenience method returns false for obvious non-citations' do
      result = Detector::Citation.new(terms('hi').phrase)

      assert_not result.detection?
    end

    test 'record method does relevant work' do
      detection_count = Detection.count
      t = terms('citation')

      Detector::Citation.record(t)

      assert_equal detection_count + 1, Detection.count
    end

    test 'record method does nothing when not needed' do
      detection_count = Detection.count
      t = terms('hi')

      Detector::Citation.record(t)

      assert_equal detection_count, Detection.count
    end

    test 'record method respects changes to the DETECTOR_VERSION value' do
      # Create a relevant detection
      t = terms('citation')
      Detector::Citation.record(t)

      detection_count = Detection.count

      # Calling the record method again doesn't do anything, but does not error.
      Detector::Citation.record(t)

      assert_equal detection_count, Detection.count

      # Calling the record method after DETECTOR_VERSION is incremented results in a new Detection.
      ClimateControl.modify DETECTOR_VERSION: 'updated' do
        Detector::Citation.record(t)

        assert_equal detection_count + 1, Detection.count
      end
    end

    test 'detections returns nil when score is lower than configured' do
      result = Detector::Citation.new('nothing here')

      assert_equal 0, result.score
      assert_nil result.detections
    end

    test 'detections returns expected array when score is higher than configured' do
      result = Detector::Citation.new(terms('citation').phrase)

      assert_equal result.summary, result.detections[0]
      assert_equal result.patterns, result.detections[1]
      assert_equal result.score, result.detections[2]
    end
  end
end
