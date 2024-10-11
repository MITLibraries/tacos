# frozen_string_literal: true

require 'test_helper'

class MetricsHelperTest < ActionView::TestCase
  def metric
    Metrics::Algorithms.new(
      month: DateTime.now - 1.month,
      doi: 1,
      issn: 2,
      isbn: 3,
      pmid: 4,
      unmatched: 79,
      journal_exact: 5,
      suggested_resource_exact: 6,
      created_at: DateTime.now,
      updated_at: DateTime.now
    )
  end
  test 'can calculate a percentage of matches for a record' do
    assert_in_delta(21.0, percent_match(metric), 0.01)
  end

  test 'can calculate sum of matches for a record' do
    assert_in_delta(21.0, sum_matched(metric), 0.01)
  end

  test 'can calculate sum of all events for a record' do
    assert_in_delta(100.0, sum_total(metric), 0.01)
  end
end
