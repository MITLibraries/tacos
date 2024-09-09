# frozen_string_literal: true

# == Schema Information
#
# Table name: detectors
#
#  id         :integer          not null, primary key
#  name       :string
#  confidence :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class DetectorTest < ActiveSupport::TestCase
  test 'duplicate Detectors are not allowed' do
    detector_count = Detector.count
    Detector.create!(name: 'Example')
    assert_equal(detector_count + 1, Detector.count)

    assert_raises(ActiveRecord::RecordNotUnique) do
      Detector.create!(name: 'Example')
    end
  end

  test 'destroying a Detector will delete associated DetectorCategories' do
    detector_count = Detector.count
    link_count = DetectorCategory.count
    record = detectors('doi')
    link_detector = record.detector_categories.count

    record.destroy

    assert_equal(detector_count - 1, Detector.count)
    assert_equal(link_count - link_detector, DetectorCategory.count)
  end

  test 'destroying a Detector will not delete associated Categories' do
    detector_count = Detector.count
    category_count = Category.count
    record = detectors('doi')

    record.destroy

    assert_equal(detector_count - 1, Detector.count)
    assert_equal(category_count, Category.count)
  end
end
