# frozen_string_literal: true

# == Schema Information
#
# Table name: search_events
#
#  id         :integer          not null, primary key
#  term_id    :integer
#  source     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class SearchEventTest < ActiveSupport::TestCase
  test 'term is required' do
    s = search_events('timdex_cool')
    assert(s.valid?)

    s.term = nil
    refute(s.valid?)
  end

  test 'source is required' do
    s = search_events('timdex_cool')
    assert(s.valid?)

    s.source = nil
    refute(s.valid?)
  end
end
