# frozen_string_literal: true

# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  phrase     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class TermTest < ActiveSupport::TestCase
  test 'duplicate terms are not allowed' do
    initial_count = Term.count
    Term.create!(phrase: 'popcorn')

    post_create_count = Term.count

    assert_equal((initial_count + 1), post_create_count)

    assert_raises(ActiveRecord::RecordNotUnique) do
      Term.create!(phrase: 'popcorn')
    end

    post_duplicate_count = Term.count

    assert_equal(post_create_count, post_duplicate_count)
  end

  test 'destroying a Term will delete associated SearchEvents' do
    term_pre_count = Term.count
    event_pre_count = SearchEvent.count

    term = terms('hi')
    term.destroy

    assert_equal((term_pre_count - 1), Term.count)
    assert(SearchEvent.count < event_pre_count)
  end

  test 'destroying a SearchEvent does not delete the Term' do
    t = terms('hi')
    s = t.search_events.first

    events_count = t.search_events.count

    assert_equal(events_count, t.search_events.count)

    s.destroy
    t.reload

    assert_equal(events_count - 1, t.search_events.count)
    assert(t.valid?)
  end
end
