# frozen_string_literal: true

# == Schema Information
#
# Table name: detections
#
#  id               :integer          not null, primary key
#  term_id          :integer          not null
#  detector_id      :integer          not null
#  detector_version :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'test_helper'

class DetectionTest < ActiveSupport::TestCase
  test 'duplicate detections are not allowed' do
    initial_count = Detection.count

    sample = {
      term: terms('hi'),
      detector: detectors('doi')
    }

    Detection.create!(sample)

    post_count = Detection.count

    assert_equal(initial_count + 1, post_count)

    assert_raises(ActiveRecord::RecordNotSaved) do
      Detection.create!(sample)
    end

    post_duplicate_count = Detection.count

    assert_equal(post_count, post_duplicate_count)
  end

  test 'new detections are allowed when detector_version is updated' do
    initial_count = Detection.count

    sample = Detection.first

    new_sample = {
      term: sample.term,
      detector: sample.detector
    }

    # A purely duplicate record fails to save...
    assert_raises(ActiveRecord::RecordNotSaved) do
      Detection.create!(new_sample)
    end

    # ...but when we update the DETECTOR_VERSION env, now the same record does save.
    new_version = 'updated'

    assert_not_equal(ENV.fetch('DETECTOR_VERSION'), new_version)

    ENV['DETECTOR_VERSION'] = new_version

    Detection.create!(new_sample)

    assert_equal(initial_count + 1, Detection.count)
  end

  test 'detections are assigned the current DETECTOR_VERSION value from env' do
    new_detection = {
      term: terms('hi'),
      detector: detectors('pmid')
    }

    Detection.create!(new_detection)

    confirmation = Detection.last

    assert_equal(confirmation.detector_version, ENV.fetch('DETECTOR_VERSION'))
  end

  test 'detector current scope filters on current env value' do
    count = Detection.current.count

    new_version = 'updated'

    assert_not_equal(ENV.fetch('DETECTOR_VERSION'), new_version)

    ENV['DETECTOR_VERSION'] = new_version

    updated_count = Detection.current.count

    assert_not_equal(count, updated_count)
  end
end
