# frozen_string_literal: true

# == Schema Information
#
# Table name: suggested_resources
#
#  id          :integer          not null, primary key
#  title       :string
#  url         :string
#  phrase      :string
#  fingerprint :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'test_helper'

class Detector
  class SuggestedResourceTest < ActiveSupport::TestCase
    test 'fingerprint matches on search term' do
      expected = suggested_resources('jstor')
      actual = Detector::SuggestedResource.full_term_match('jstor')

      assert_equal 1, actual.count
      assert_equal expected, actual.first
    end

    test 'fingerprint matches on any word order or punctuation' do
      expected = suggested_resources('nobel_laureate')
      actual_one = Detector::SuggestedResource.full_term_match('Moungi Bawendi')
      actual_two = Detector::SuggestedResource.full_term_match('Bawendi, Moungi')

      assert_equal 1, actual_one.count
      assert_equal expected, actual_one.first
      assert_equal actual_one.first, actual_two.first
    end

    test 'partial fingerprint matches do not count' do
      actual_partial = Detector::SuggestedResource.full_term_match('science web')
      actual_extra = Detector::SuggestedResource.full_term_match('the web of science')

      assert_predicate actual_partial.count, :zero?
      assert_predicate actual_extra.count, :zero?
    end

    test 'record does relevant work' do
      detection_count = Detection.count
      t = terms('jstor')

      Detector::SuggestedResource.record(t)

      assert_equal(detection_count + 1, Detection.count)
    end

    test 'record does nothing when not needed' do
      detection_count = Detection.count
      t = terms('isbn_9781319145446')

      Detector::SuggestedResource.record(t)

      assert_equal(detection_count, Detection.count)
    end

    test 'record respects changes to the DETECTOR_VERSION value' do
      # Create a relevant detection
      Detector::SuggestedResource.record(terms('jstor'))

      detection_count = Detection.count

      # Calling the record method again doesn't do anything, but does not error.
      Detector::SuggestedResource.record(terms('jstor'))

      assert_equal(detection_count, Detection.count)

      # Calling the record method after DETECTOR_VERSION is incremented results in a new Detection
      ClimateControl.modify DETECTOR_VERSION: 'updated' do
        Detector::SuggestedResource.record(terms('jstor'))

        assert_equal detection_count + 1, Detection.count
      end
    end
  end
end
