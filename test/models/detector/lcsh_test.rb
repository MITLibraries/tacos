# frozen_string_literal: true

require 'test_helper'

class Detector
  class LcshTest < ActiveSupport::TestCase
    test 'lcsh detector activates when a separator is found' do
      true_samples = [
        'Geology -- Massachusetts',
        'Space vehicles -- Materials -- Congresses'
      ]

      true_samples.each do |term|
        actual = Detector::Lcsh.new(term).identifiers

        assert_includes(actual, :separator)
      end
    end

    test 'lcsh detector does nothing in most cases' do
      false_samples = [
        'orange cats like popcorn',
        'hyphenated names like Lin-Manuel Miranda do nothing',
        'dashes used as an aside - like this one - do nothing',
        'This one should--also not work'
      ]

      false_samples.each do |term|
        actual = Detector::Lcsh.new(term).identifiers

        assert_not_includes(actual, :separator)
      end
    end

    test 'record method does relevant work' do
      detection_count = Detection.count
      t = terms('lcsh')

      Detector::Lcsh.record(t)

      assert_equal(detection_count + 1, Detection.count)
    end

    test 'record does nothing when not needed' do
      detection_count = Detection.count
      t = terms('isbn_9781319145446')

      Detector::Lcsh.record(t)

      assert_equal(detection_count, Detection.count)
    end
  end
end
