# frozen_string_literal: true

# == Schema Information
#
# Table name: detector_journals
#
#  id              :integer          not null, primary key
#  name            :string
#  additional_info :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'test_helper'

class Detector
  class JournalTest < ActiveSupport::TestCase
    test 'exact term match on journal name' do
      expected = detector_journals('the_new_england_journal_of_medicine')
      actual = Detector::Journal.full_term_match('the new england journal of medicine')

      assert_equal 1, actual.count
      assert_equal(expected, actual.first)
    end

    test 'mixed case exact term match on journal name' do
      expected = detector_journals('the_new_england_journal_of_medicine')
      actual = Detector::Journal.full_term_match('The New England Journal of Medicine')

      assert_equal 1, actual.count
      assert_equal(expected, actual.first)
    end

    test 'exact match within longer term returns no matches' do
      actual = Detector::Journal.full_term_match('The New England Journal of Medicine, 1999')

      assert_predicate actual.count, :zero?
    end

    test 'phrase match within longer term returns matches' do
      actual = Detector::Journal.partial_term_match('words and stuff The New England Journal of Medicine, 1999')

      assert_equal 1, actual.count
    end

    test 'multple matches can happen with phrase matching within longer terms' do
      actual = Detector::Journal.partial_term_match('words and stuff Nature medicine, 1999')

      assert_equal 2, actual.count
    end

    test 'mixed titles are downcased when saved' do
      mixed_case = 'ThIs Is A tItLe'
      actual = Detector::Journal.create(name: mixed_case)
      actual.reload

      assert_not_equal(mixed_case, actual.name)
      assert_equal(mixed_case.downcase, actual.name)
    end

    test 'record does relevant work' do
      detection_count = Detection.count
      t = terms('journal_nature_medicine')

      Detector::Journal.record(t)

      assert_equal(detection_count + 1, Detection.count)
    end

    test 'record does nothing when not needed' do
      detection_count = Detection.count
      t = terms('isbn_9781319145446')

      Detector::Journal.record(t)

      assert_equal(detection_count, Detection.count)
    end

    test 'record respects changes to the DETECTOR_VERSION value' do
      # Create a relevant detection
      Detector::Journal.record(terms('journal_nature_medicine'))

      detection_count = Detection.count

      # Calling the record method again doesn't do anything, but does not error.
      Detector::Journal.record(terms('journal_nature_medicine'))

      assert_equal(detection_count, Detection.count)

      # Calling the record method after DETECTOR_VERSION is incremented results in a new Detection
      ClimateControl.modify DETECTOR_VERSION: 'updated' do
        Detector::Journal.record(terms('journal_nature_medicine'))

        assert_equal detection_count + 1, Detection.count
      end
    end
  end
end
