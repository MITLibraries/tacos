# frozen_string_literal: true

# == Schema Information
#
# Table name: metrics_algorithms
#
#  id                       :integer          not null, primary key
#  month                    :date
#  doi                      :integer
#  issn                     :integer
#  isbn                     :integer
#  pmid                     :integer
#  unmatched                :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  journal_exact            :integer
#  suggested_resource_exact :integer
#
require 'test_helper'

class Algorithms < ActiveSupport::TestCase
  # Monthlies
  test 'dois counts are included in monthly aggregation' do
    aggregate = Metrics::Algorithms.new.generate(DateTime.now)

    assert_equal 1, aggregate.doi
  end

  test 'issns counts are included in monthly aggregation' do
    aggregate = Metrics::Algorithms.new.generate(DateTime.now)

    assert_equal 1, aggregate.issn
  end

  test 'isbns counts are included in monthly aggregation' do
    aggregate = Metrics::Algorithms.new.generate(DateTime.now)

    assert_equal 1, aggregate.isbn
  end

  test 'pmids counts are included in monthly aggregation' do
    aggregate = Metrics::Algorithms.new.generate(DateTime.now)

    assert_equal 1, aggregate.pmid
  end

  test 'journal exact counts are included in monthly aggregation' do
    aggregate = Metrics::Algorithms.new.generate(DateTime.now)

    assert_equal 1, aggregate.journal_exact
  end

  test 'suggested_resource exact counts are included in monthly aggregation' do
    aggregate = Metrics::Algorithms.new.generate(DateTime.now)

    assert_equal 1, aggregate.suggested_resource_exact
  end

  test 'unmatched counts are included are included in monthly aggregation' do
    aggregate = Metrics::Algorithms.new.generate(DateTime.now)

    assert_equal 2, aggregate.unmatched
  end

  test 'searches with multiple patterns are accounted for correctly' do
    # Drop all search events to ensure the report has only what we care about.
    SearchEvent.delete_all

    SearchEvent.create(term: terms(:multiple_detections), source: 'test')

    aggregate = Metrics::Algorithms.new.generate(DateTime.now)

    assert_equal 1, aggregate.doi
    assert_equal 1, aggregate.pmid
  end

  test 'creating lots of searchevents leads to correct data for monthly' do
    # drop all searchevents to make math easier and minimize fragility over time as more fixtures are created
    SearchEvent.delete_all

    doi_expected_count = rand(1...100)
    doi_expected_count.times do
      SearchEvent.create(term: terms(:doi), source: 'test')
    end

    issn_expected_count = rand(1...100)
    issn_expected_count.times do
      SearchEvent.create(term: terms(:issn_1075_8623), source: 'test')
    end

    isbn_expected_count = rand(1...100)
    isbn_expected_count.times do
      SearchEvent.create(term: terms(:isbn_9781319145446), source: 'test')
    end

    pmid_expected_count = rand(1...100)
    pmid_expected_count.times do
      SearchEvent.create(term: terms(:pmid_38908367), source: 'test')
    end

    unmatched_expected_count = rand(1...100)
    unmatched_expected_count.times do
      SearchEvent.create(term: terms(:hi), source: 'test')
    end

    aggregate = Metrics::Algorithms.new.generate(DateTime.now)

    assert_equal doi_expected_count, aggregate.doi
    assert_equal issn_expected_count, aggregate.issn
    assert_equal isbn_expected_count, aggregate.isbn
    assert_equal pmid_expected_count, aggregate.pmid
    assert_equal unmatched_expected_count, aggregate.unmatched
  end

  # Total
  test 'dois counts are included in total aggregation' do
    aggregate = Metrics::Algorithms.new.generate

    assert_equal 1, aggregate.doi
  end

  test 'issns counts are included in total aggregation' do
    aggregate = Metrics::Algorithms.new.generate

    assert_equal 1, aggregate.issn
  end

  test 'isbns counts are included in total aggregation' do
    aggregate = Metrics::Algorithms.new.generate

    assert_equal 1, aggregate.isbn
  end

  test 'pmids counts are included in total aggregation' do
    aggregate = Metrics::Algorithms.new.generate

    assert_equal 2, aggregate.pmid
  end

  test 'journal exact counts are included in total aggregation' do
    aggregate = Metrics::Algorithms.new.generate

    assert_equal 2, aggregate.journal_exact
  end

  test 'suggested_resource exact counts are included in total aggregation' do
    aggregate = Metrics::Algorithms.new.generate

    assert_equal 2, aggregate.suggested_resource_exact
  end

  test 'unmatched counts are included are included in total aggregation' do
    aggregate = Metrics::Algorithms.new.generate

    assert_equal 2, aggregate.unmatched
  end

  test 'creating lots of searchevents leads to correct data for total' do
    # drop all searchevents to make math easier and minimize fragility over time as more fixtures are created
    SearchEvent.delete_all

    doi_expected_count = rand(1...100)
    doi_expected_count.times do
      SearchEvent.create(term: terms(:doi), source: 'test')
    end

    issn_expected_count = rand(1...100)
    issn_expected_count.times do
      SearchEvent.create(term: terms(:issn_1075_8623), source: 'test')
    end

    isbn_expected_count = rand(1...100)
    isbn_expected_count.times do
      SearchEvent.create(term: terms(:isbn_9781319145446), source: 'test')
    end

    pmid_expected_count = rand(1...100)
    pmid_expected_count.times do
      SearchEvent.create(term: terms(:pmid_38908367), source: 'test')
    end

    journal_exact_count = rand(1...100)
    journal_exact_count.times do
      SearchEvent.create(term: terms(:journal_nature_medicine), source: 'test')
    end

    suggested_resource_exact_count = rand(1...100)
    suggested_resource_exact_count.times do
      SearchEvent.create(term: terms(:suggested_resource_jstor), source: 'test')
    end

    unmatched_expected_count = rand(1...100)
    unmatched_expected_count.times do
      SearchEvent.create(term: terms(:hi), source: 'test')
    end

    aggregate = Metrics::Algorithms.new.generate

    assert_equal doi_expected_count, aggregate.doi
    assert_equal issn_expected_count, aggregate.issn
    assert_equal isbn_expected_count, aggregate.isbn
    assert_equal pmid_expected_count, aggregate.pmid
    assert_equal journal_exact_count, aggregate.journal_exact
    assert_equal suggested_resource_exact_count, aggregate.suggested_resource_exact
    assert_equal unmatched_expected_count, aggregate.unmatched
  end
end
