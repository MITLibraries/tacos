# frozen_string_literal: true

# == Schema Information
#
# Table name: suggested_patterns
#
#  id          :integer          not null, primary key
#  title       :string           not null
#  url         :string           not null
#  pattern     :string           not null
#  shortcode   :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#  confidence  :float            default(0.9)
#
require 'test_helper'

class SuggestedPatternTest < ActiveSupport::TestCase
  test 'title is required' do
    sp = suggested_patterns('astm')

    assert_predicate sp, :valid?

    sp.title = nil

    assert_not_predicate sp, :valid?
  end

  test 'url is required' do
    sp = suggested_patterns('astm')

    assert_predicate sp, :valid?

    sp.url = nil

    assert_not_predicate sp, :valid?
  end

  test 'pattern is required' do
    sp = suggested_patterns('astm')

    assert_predicate sp, :valid?

    sp.pattern = nil

    assert_not_predicate sp, :valid?
  end

  test 'shortcode is required' do
    sp = suggested_patterns('astm')

    assert_predicate sp, :valid?

    sp.shortcode = nil

    assert_not_predicate sp, :valid?
  end

  test 'pattern must be unique' do
    sp = suggested_patterns('astm')

    sp2 = SuggestedPattern.new
    sp2.title = 'a title'
    sp2.url = 'https://example.com'
    sp2.pattern = sp.pattern
    sp2.shortcode = 's2'

    assert_not_predicate sp2, :valid?
  end

  test 'shortcode must be unique' do
    sp = suggested_patterns('astm')

    sp2 = SuggestedPattern.new
    sp2.title = 'a title'
    sp2.url = 'https://example.com'
    sp2.pattern = '(hi2)'
    sp2.shortcode = sp.shortcode

    assert_not_predicate sp2, :valid?
  end
end
