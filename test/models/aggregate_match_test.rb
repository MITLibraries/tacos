# == Schema Information
#
# Table name: aggregate_matches
#
#  id         :integer          not null, primary key
#  doi        :integer
#  issn       :integer
#  isbn       :integer
#  pmid       :integer
#  unmatched  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class AggregateMatchTest < ActiveSupport::TestCase
  test 'dois counts are included in aggregation' do
    aggregate = AggregateMatch.new.generate
    assert aggregate.doi == 1
  end

  test 'issns counts are included in aggregation' do
    aggregate = AggregateMatch.new.generate
    assert aggregate.issn == 1
  end

  test 'isbns counts are included in aggregation' do
    aggregate = AggregateMatch.new.generate
    assert aggregate.isbn == 1
  end

  test 'pmids counts are included in aggregation' do
    aggregate = AggregateMatch.new.generate
    assert aggregate.pmid == 2
  end

  test 'unmatched counts are included are included in aggregation' do
    aggregate = AggregateMatch.new.generate
    assert aggregate.unmatched == 2
  end

  test 'creating lots of searchevents leads to correct data' do
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

    aggregate = AggregateMatch.new.generate

    assert doi_expected_count == aggregate.doi
    assert issn_expected_count == aggregate.issn
    assert isbn_expected_count == aggregate.isbn
    assert pmid_expected_count == aggregate.pmid
    assert unmatched_expected_count == aggregate.unmatched
  end
end
