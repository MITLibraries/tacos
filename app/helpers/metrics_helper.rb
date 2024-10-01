# frozen_string_literal: true

module MetricsHelper
  # Calculate percentage of search events in which we had any Detection match
  def percent_match(metric)
    (sum_matched(metric) / sum_total(metric) * 100).round(2)
  end

  # Sums all detection matches for a given Metrics::Algorithms record
  def sum_matched(metric)
    metric.doi.to_f + metric.issn.to_f + metric.isbn.to_f + metric.pmid.to_f + metric.journal_exact.to_f + metric.suggested_resource_exact.to_f
  end

  # Calculates total events for a given Metrics::Algorithms record
  def sum_total(metric)
    sum_matched(metric) + metric.unmatched.to_f
  end
end
