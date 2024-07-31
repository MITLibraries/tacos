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

module Detector
  class JournalTest < ActiveSupport::TestCase
    test 'exact term match on journal name' do
      expected = detector_journals('the_new_england_journal_of_medicine')
      actual = Detector::Journal.full_term_match('the new england journal of medicine')

      assert actual.count == 1
      assert_equal(expected, actual.first)
    end

    test 'mixed case exact term match on journal name' do
      expected = detector_journals('the_new_england_journal_of_medicine')
      actual = Detector::Journal.full_term_match('The New England Journal of Medicine')

      assert actual.count == 1
      assert_equal(expected, actual.first)
    end

    test 'exact match within longer term returns no matches' do
      actual = Detector::Journal.full_term_match('The New England Journal of Medicine, 1999')
      assert actual.count.zero?
    end

    test 'phrase match within longer term returns matches' do
      actual = Detector::Journal.partial_term_match('words and stuff The New England Journal of Medicine, 1999')
      assert actual.count == 1
    end

    test 'multple matches can happen with phrase matching within longer terms' do
      actual = Detector::Journal.partial_term_match('words and stuff Nature medicine, 1999')
      assert actual.count == 2
    end

    test 'mixed titles are downcased when saved' do
      mixed_case = 'ThIs Is A tItLe'
      actual = Detector::Journal.create(name: mixed_case)
      actual.reload
      refute_equal(mixed_case, actual.name)
      assert_equal(mixed_case.downcase, actual.name)
    end
  end
end
