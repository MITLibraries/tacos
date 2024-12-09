# frozen_string_literal: true

# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  phrase     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  flag       :boolean
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
    assert_operator(SearchEvent.count, :<, event_pre_count)
  end

  test 'destroying a Term will delete associated Detections' do
    term_pre_count = Term.count
    detection_pre_count = Detection.count

    term = terms('doi')
    term.destroy

    assert_equal((term_pre_count - 1), Term.count)
    assert_operator(Detection.count, :<, detection_pre_count)
  end

  test 'destroying a Term will delete associated Categorizations' do
    term_pre_count = Term.count
    categorization_pre_count = Categorization.count

    term = terms('doi')
    term.destroy

    assert_equal((term_pre_count - 1), Term.count)
    assert_operator(Categorization.count, :<, categorization_pre_count)
  end

  test 'destroying a Term will delete associated Confirmations' do
    term_count = Term.count
    confirmation_count = Confirmation.count

    term = terms('lcsh')

    relevant_links = term.confirmations.count

    assert_operator(0, :<, relevant_links)

    term.destroy

    assert_equal(term_count - 1, Term.count)
    assert_equal(confirmation_count - relevant_links, Confirmation.count)
  end

  test 'destroying a SearchEvent does not delete the Term' do
    t = terms('hi')
    s = t.search_events.first

    events_count = t.search_events.count

    assert_equal(events_count, t.search_events.count)

    s.destroy
    t.reload

    assert_equal(events_count - 1, t.search_events.count)
    assert_predicate(t, :valid?)
  end

  test 'destroying a Detection does not delete the Term' do
    t = terms('doi')
    d = Detection.where(term: t).first
    terms_count = Term.count
    detections_count = t.detections.count

    assert_operator(0, :<, detections_count)

    d.destroy
    t.reload

    assert_equal(terms_count, Term.count)
    assert_predicate(t, :valid?)
  end

  test 'destroying a Categorization does not delete the Term' do
    t = terms('doi')
    c = Categorization.where(term: t).first
    terms_count = Term.count
    categorizations_count = t.categorizations.count

    assert_operator(0, :<, categorizations_count)

    c.destroy
    t.reload

    assert_equal(terms_count, Term.count)
    assert_predicate(t, :valid?)
  end

  test 'record_detections can be re-run without new records being created' do
    t = terms('doi')

    t.record_detections

    detection_count = Detection.count

    t.record_detections

    assert_equal(detection_count, Detection.count)
  end

  test 'calculate_confidence returns an average of a list with multiple numbers' do
    t = Term.new

    input = [0.0, 1.0]

    assert_in_delta(0.5, t.calculate_confidence(input))
  end

  test 'calculate_confidence returns an average of a list with one number' do
    t = Term.new

    input = [0.33]

    assert_in_delta(0.33, t.calculate_confidence(input))
  end

  test 'calculate_confidence only returns two decimal places' do
    t = Term.new

    input = [0.3141592653]

    assert_in_delta(0.31, t.calculate_confidence(input))
  end

  test 'calculate_categorization spawns new Categorization records' do
    categorization_count = Categorization.count

    t = Term.create!(phrase: 'The crisis of reproducibility 10.1007/s11538-018-0497-0')
    t.calculate_categorizations

    assert_operator(categorization_count, :<, Categorization.count)
  end

  test 're-running calculate_categorization does not create yet more records' do
    t = Term.create!(phrase: 'The crisis of reproducibility 10.1007/s11538-018-0497-0')

    t.calculate_categorizations

    after_count = Categorization.count

    t.calculate_categorizations

    repeat_count = Categorization.count

    assert_equal(after_count, repeat_count)
  end

  test 'running calculate_categorizations when DETECTOR_VERSION changes results in new records' do
    t = terms('journal_nature_medicine')

    t.calculate_categorizations

    categorization_count = Categorization.count

    t.calculate_categorizations

    assert_equal categorization_count, Categorization.count

    ClimateControl.modify DETECTOR_VERSION: 'updated' do
      t.calculate_categorizations

      assert_equal categorization_count + 1, Categorization.count
    end
  end

  test 'user_confirmed scope returns an active record relation' do
    assert_kind_of ActiveRecord::Relation, Term.user_confirmed
  end

  test 'user_unconfirmed scope returns an active record relation' do
    assert_kind_of ActiveRecord::Relation, Term.user_unconfirmed
  end

  test 'user_confirmed scope includes terms with manual confirmations' do
    confirmed_count = Term.user_confirmed.count
    t = terms('doi')

    # Make sure that this term isn't yet confirmed
    assert_equal 0, t.confirmations.count

    new_record = {
      term: t,
      user: users('basic'),
      category: categories('transactional')
    }
    Confirmation.create!(new_record)

    # The count should now be one more.
    assert_equal confirmed_count + 1, Term.user_confirmed.count
  end

  test 'user_confirmed scope accounts for terms with multiple manual confirmations' do
    confirmed_count = Term.user_confirmed.count
    t = terms('lcsh')

    # Confirm this term has already been categorized manually (see fixtures)
    assert_operator 1, :<=, t.confirmations.count

    new_record = {
      term: t,
      user: users('basic'),
      category: categories('transactional')
    }
    Confirmation.create!(new_record)

    # The count should be unchanged
    assert_equal confirmed_count, Term.user_confirmed.count
  end

  test 'user_unconfirmed scope accounts for new manual confirmations' do
    unconfirmed_count = Term.user_unconfirmed.count
    t = terms('doi')

    # Confirm this term is not yet categorized
    assert_equal 0, t.confirmations.count

    new_record = {
      term: t,
      user: users('basic'),
      category: categories('transactional')
    }
    Confirmation.create!(new_record)

    # The count should now be one less.
    assert_equal unconfirmed_count - 1, Term.user_unconfirmed.count
  end
end
