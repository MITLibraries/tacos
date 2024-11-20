# frozen_string_literal: true

#
require 'test_helper'

class SearchLoggerTest < ActiveSupport::TestCase
  test 'a term is created if it does not exist' do
    orig_term_count = Term.count
    phrase = 'a term is created if it does not exist'
    SearchLogger.logevent(phrase, 'search logger test')

    assert_operator(Term.count, :>, orig_term_count)
  end

  test 'a term is not created if it already exists' do
    orig_term_count = Term.count
    phrase = Term.first.phrase
    SearchLogger.logevent(phrase, 'search logger test')

    assert_equal(orig_term_count, Term.count)
  end

  test 'a new search event is created for an existing term' do
    orig_searchevent_count = SearchEvent.count
    phrase = Term.first.phrase
    SearchLogger.logevent(phrase, 'search logger test')

    assert_equal(orig_searchevent_count + 1, SearchEvent.count)
  end

  test 'a new search event is created for a new term' do
    orig_searchevent_count = SearchEvent.count
    phrase = 'a new search event is created for a new term'
    SearchLogger.logevent(phrase, 'search logger test')

    assert_equal(orig_searchevent_count + 1, SearchEvent.count)
  end
end
