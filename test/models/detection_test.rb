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
#  validatable_type :string
#  validatable_id   :integer
#
require 'test_helper'

class DetectionTest < ActiveSupport::TestCase
  test 'duplicate detections are not allowed' do
    initial_count = Detection.count

    sample = {
      term: terms('hi'),
      detector: detectors('doi'),
      detector_version: '1'
    }

    Detection.create!(sample)

    post_count = Detection.count

    assert_equal(initial_count + 1, post_count)

    assert_raises(ActiveRecord::RecordNotUnique) do
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
      detector: sample.detector,
      detector_version: '1'
    }

    # A purely duplicate record fails to save...
    assert_raises(ActiveRecord::RecordNotUnique) do
      Detection.create!(new_sample)
    end

    # ...but when we update the DETECTOR_VERSION env, now the same record does save.
    new_sample[:detector_version] = '2'
    Detection.create!(new_sample)

    assert_equal(initial_count + 1, Detection.count)
  end

  test 'detector current scope filters on current env value' do
    count = Detection.current.count

    new_version = 'updated'

    assert_not_equal(ENV.fetch('DETECTOR_VERSION'), new_version)

    ClimateControl.modify DETECTOR_VERSION: new_version do
      updated_count = Detection.current.count

      assert_not_equal(count, updated_count)
    end
  end

  test 'scores returns an array of hashes summarizing the categories in a detection' do
    example = detections('one')

    assert_equal(example.scores.class, Array)
    assert_equal(example.scores.first.class, Hash)

    assert_equal(example.detector.detector_categories.length, example.scores.length)
  end

  test 'scores will return multiple values if that detector is linked to multiple categories' do
    example = detections('one')
    original_scores_length = example.scores.length

    assert_equal(1, example.detector.categories.length)
    assert_not_equal(categories('navigational'), example.detector.categories.first)

    DetectorCategory.create(
      detector: example.detector,
      category: categories('navigational'),
      confidence: 0.15
    )

    example.reload

    assert_equal(example.detector.detector_categories.length, original_scores_length + 1)
  end
end
