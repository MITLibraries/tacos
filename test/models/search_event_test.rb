# frozen_string_literal: true

# == Schema Information
#
# Table name: search_events
#
#  id         :integer          not null, primary key
#  source     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  term_id    :integer
#
# Indexes
#
#  index_search_events_on_source   (source)
#  index_search_events_on_term_id  (term_id)
#
require 'test_helper'

class SearchEventTest < ActiveSupport::TestCase
  test 'term is required' do
    s = search_events('timdex_cool')

    assert_predicate(s, :valid?)

    s.term = nil

    assert_not_predicate(s, :valid?)
  end

  test 'source is required' do
    s = search_events('timdex_cool')

    assert_predicate(s, :valid?)

    s.source = nil

    assert_not_predicate(s, :valid?)
  end

  test 'monthly scope returns requested month of SearchEvents' do
    assert_includes SearchEvent.all, search_events(:current_month_pmid)
    assert_includes SearchEvent.single_month(Time.zone.now), search_events(:current_month_pmid)
  end

  test 'monthly scope does not return SearchEvents outside the requested month' do
    assert_includes SearchEvent.all, search_events(:old_month_pmid)
    assert_not_includes SearchEvent.single_month(Time.zone.now), search_events(:old_month_pmid)
  end
end
