# frozen_string_literal: true

# == Schema Information
#
# Table name: categorizations
#
#  id               :integer          not null, primary key
#  category_id      :integer          not null
#  term_id          :integer          not null
#  confidence       :float
#  detector_version :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'test_helper'

class CategorizationTest < ActiveSupport::TestCase
  test 'duplicate categorizations are not allowed' do
    initial_count = Categorization.count

    sample = {
      term: terms('hi'),
      category: categories('transactional'),
      confidence: 0.5
    }

    Categorization.create!(sample)

    post_count = Categorization.count

    assert_equal(initial_count + 1, post_count)

    assert_raises(ActiveRecord::RecordNotUnique) do
      Categorization.create!(sample)
    end

    post_duplicate_count = Categorization.count

    assert_equal(post_count, post_duplicate_count)
  end

  test 'new categorizations are allowed when detector_version is updated' do
    initial_count = Categorization.count

    sample = Categorization.first

    new_sample = {
      term: sample.term,
      category: sample.category,
      confidence: sample.confidence
    }

    # A purely duplicate record fails to save...
    assert_raises(ActiveRecord::RecordNotUnique) do
      Categorization.create!(new_sample)
    end

    # ...but when we update the DETECTOR_VERSION env, now the same record does save.
    new_version = 'updated'

    assert_not_equal(ENV.fetch('DETECTOR_VERSION'), new_version)

    ClimateControl.modify DETECTOR_VERSION: new_version do
      Categorization.create!(new_sample)

      assert_equal(initial_count + 1, Categorization.count)
    end
  end

  test 'categorizations are assigned the current DETECTOR_VERSION value from env' do
    new_categorization = {
      term: terms('hi'),
      category: categories('transactional'),
      confidence: 0.96
    }

    Categorization.create!(new_categorization)

    confirmation = Categorization.last

    assert_equal(confirmation.detector_version, ENV.fetch('DETECTOR_VERSION'))
  end

  test 'categorization current scope filters on current env value' do
    count = Categorization.current.count

    new_version = 'updated'

    assert_not_equal(ENV.fetch('DETECTOR_VERSION'), new_version)

    ClimateControl.modify DETECTOR_VERSION: new_version do
      updated_count = Categorization.current.count

      assert_not_equal(count, updated_count)
    end
  end
end
