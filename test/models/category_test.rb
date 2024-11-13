# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test 'duplicate Categories are not allowed' do
    initial_count = Category.count
    Category.create!(name: 'Example')

    assert_equal(initial_count + 1, Category.count)

    assert_raises(ActiveRecord::RecordNotUnique) do
      Category.create!(name: 'Example')
    end
  end

  test 'destroying a Category will delete associated DetectorCategories' do
    category_count = Category.count
    link_count = DetectorCategory.count
    record = categories('transactional')
    link_category = record.detector_categories.count

    record.destroy

    assert_equal(category_count - 1, Category.count)
    assert_equal(link_count - link_category, DetectorCategory.count)
  end

  test 'destroying a Category will not delete associated Detectors' do
    category_count = Category.count
    detector_count = Detector.count
    record = categories('transactional')

    record.destroy

    assert_equal(category_count - 1, Category.count)
    assert_equal(detector_count, Detector.count)
  end

  test 'destroying a Category will delete associated Categorizations' do
    category_count = Category.count
    categorization_count = Categorization.count

    record = categories('transactional')

    relevant_links = record.categorizations.count

    assert_operator(0, :<, relevant_links)

    record.destroy

    assert_equal(category_count - 1, Category.count)
    assert_equal(categorization_count - relevant_links, Categorization.count)
  end

  test 'destroying a Category will delete associated Confirmations' do
    category_count = Category.count
    confirmation_count = Confirmation.count

    record = categories('transactional')

    relevant_links = record.confirmations.count

    assert_operator(0, :<, relevant_links)

    record.destroy

    assert_equal(category_count - 1, Category.count)
    assert_equal(confirmation_count - relevant_links, Confirmation.count)
  end
end
