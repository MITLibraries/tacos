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

  test 'monthly scope returns requested month of SearchEvents' do
    assert SearchEvent.all.include?(search_events(:current_month_pmid))
    assert SearchEvent.single_month(Time.now).include?(search_events(:current_month_pmid))
  end

  test 'monthly scope does not return SearchEvents outside the requested month' do
    assert SearchEvent.all.include?(search_events(:old_month_pmid))
    refute SearchEvent.single_month(Time.now).include?(search_events(:old_month_pmid))
  end
end
