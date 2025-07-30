# frozen_string_literal: true

# == Schema Information
#
# Table name: terms
#
#  id                    :integer          not null, primary key
#  phrase                :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  flag                  :boolean
#  fingerprint_id        :integer
#  suggested_resource_id :integer
#
require 'test_helper'

class TermTest < ActiveSupport::TestCase
  test 'duplicate terms are not allowed' do
    initial_count = Term.count
    Term.create!(phrase: 'popcorn')

    post_create_count = Term.count

    assert_equal(initial_count + 1, post_create_count)

    assert_raises(ActiveRecord::RecordNotUnique) do
      Term.create!(phrase: 'popcorn')
    end

    post_duplicate_count = Term.count

    assert_equal(post_create_count, post_duplicate_count)
  end

  test 'Creating a term will spawn its associated fingerprint' do
    term_count = Term.count
    fingerprint_count = Fingerprint.count

    new_term = {
      phrase: 'foo'
    }

    assert_nil Fingerprint.find_by(value: 'foo')

    Term.create!(new_term)

    assert_equal term_count + 1, Term.count
    assert_equal fingerprint_count + 1, Fingerprint.count
  end

  test 'destroying a Term will delete associated SearchEvents' do
    term_pre_count = Term.count
    event_pre_count = SearchEvent.count

    term = terms('hi')
    term.destroy

    assert_equal(term_pre_count - 1, Term.count)
    assert_operator(SearchEvent.count, :<, event_pre_count)
  end

  test 'destroying a Term will delete associated Detections' do
    term_pre_count = Term.count
    detection_pre_count = Detection.count

    term = terms('doi')
    term.destroy

    assert_equal(term_pre_count - 1, Term.count)
    assert_operator(Detection.count, :<, detection_pre_count)
  end

  test 'destroying a Term will delete associated Categorizations' do
    term_pre_count = Term.count
    categorization_pre_count = Categorization.count

    term = terms('doi')
    term.destroy

    assert_equal(term_pre_count - 1, Term.count)
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

  test 'destroying a Term will delete its Fingerprint if no cluster exists' do
    term = terms('hi')
    term.save
    term.reload

    term_pre_count = Term.count
    fingerprints_pre_count = Fingerprint.count

    assert_equal 1, term.fingerprint.terms.count

    term.destroy

    assert_equal term_pre_count - 1, Term.count
    assert_equal fingerprints_pre_count - 1, Fingerprint.count
  end

  test 'destroying a Term will not delete its Fingerprint if other terms exist in that cluster' do
    # Setup
    term = terms('cool')
    term_cluster = terms('cool_cluster')
    term.save
    term_cluster.save
    term.reload

    # Initial conditions
    term_pre_count = Term.count
    fingerprints_pre_count = Fingerprint.count
    fingerprint = term.fingerprint
    cluster_size = fingerprint.terms.count

    assert_operator 1, :<, cluster_size

    # Change
    term.destroy

    # Verify impact
    assert_equal term_pre_count - 1, Term.count
    assert_equal fingerprints_pre_count, Fingerprint.count
    assert_equal cluster_size - 1, fingerprint.terms.count
  end

  # This test, and maybe the actual dynamic, may need to be refactored. For right now I'm confirming this behavior via
  # the test here.
  test 'a Term without a Fingerprint is valid (but regenerates on next save)' do
    target_term = terms('hi')
    target_fingerprint = target_term.fingerprint

    assert_not_nil target_term.fingerprint

    target_fingerprint.destroy
    target_term.reload

    assert_nil target_term.fingerprint
    assert_predicate target_term, :valid?

    target_term.save

    assert_not_nil target_term.fingerprint
    assert_predicate target_term, :valid?
  end

  test 'deleting a Term without a Fingerprint succeeds without problem' do
    term_count = Term.count

    target = fingerprints('hi')
    target_term = terms('hi')

    target.destroy
    target_term.reload

    assert_predicate target_term, :valid?
    assert_instance_of NilClass, target_term.fingerprint
    assert_equal term_count, Term.count

    # Delete the term, and nothing should blow up - the after_destroy method has safe operators that allow success
    target_term.destroy

    # There is now one fewer term.
    assert_equal term_count - 1, Term.count
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

  test 'record_detections includes the external lambda with appropriate env defined' do
    # No new mlcitation is created without the lambda enabled.
    mlcitation_before_count = Detection.where(detector_id: Detector.find_by(name: 'MlCitation').id).count
    t = terms('citation')
    t.record_detections

    assert_equal mlcitation_before_count, Detection.where(detector_id: Detector.find_by(name: 'MlCitation').id).count

    # However, with the lambda enabled, the same term triggers a detection.
    with_enabled_mlcitation do
      VCR.use_cassette('lambda citation') do
        t.record_detections

        assert_operator mlcitation_before_count, :<, Detection.where(detector_id: Detector.find_by(name: 'MlCitation').id).count
      end
    end
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

  test 'calculate_categorization includes SuggestedResources with categories set' do
    sr = suggested_resources('suggested_resource_with_category')
    t = terms('suggested_resource_with_category')

    # confirm a category was set
    assert_equal(categories('transactional'), sr.category)

    # Before categorization
    categorization_count = Categorization.count

    t.calculate_categorizations

    # Expect categorization count to increase
    assert_equal categorization_count + 1, Categorization.count
  end

  test 'calculate_categorization skips SuggestedResources with categories not set' do
    sr = suggested_resources('nobel_laureate')
    t = terms('nobel_laureate')

    # confirm no category was set
    assert_nil(sr.category)

    # Before categorization
    categorization_count = Categorization.count

    t.calculate_categorizations

    # Expect no change in categorization count
    assert_equal categorization_count, Categorization.count
  end

  test 'calculate_categorization includes SuggestedPatterns with categories set' do
    sp = suggested_patterns('iso')
    t = Term.find_or_create_by(phrase: 'iso 1234')

    # confirm a category was set
    assert_equal(categories('transactional'), sp.category)

    # Before categorization
    categorization_count = Categorization.count

    t.calculate_categorizations

    # Expect categorization count to increase
    assert_equal categorization_count + 1, Categorization.count
  end

  test 'calculate_categorization skips SuggestedPatterns with categories not set' do
    sp = suggested_patterns('astm')
    t = terms('astm')

    # confirm no category was set
    assert_nil(sp.category)

    # Before categorization
    categorization_count = Categorization.count

    t.calculate_categorizations

    # Expect no change in categorization count
    assert_equal categorization_count, Categorization.count
  end

  test 'categorized scope returns an active record relation' do
    assert_kind_of ActiveRecord::Relation, Term.categorized
  end

  test 'categorized scope accounts for terms with multiple categorizations' do
    categorized_count = Term.categorized.count
    t = terms('doi')
    orig_categorization_count = t.categorizations.count

    # term has been categorized already
    assert_operator 1, :<=, orig_categorization_count

    new_record = {
      term: t,
      category: categories('navigational'),
      confidence: 0.5,
      detector_version: '1'
    }
    Categorization.create!(new_record)

    # The term has gained a category, but the categorized scope has not changed size.
    assert_operator orig_categorization_count, :<, t.categorizations.count
    assert_equal categorized_count, Term.categorized.count
  end

  test 'categorization can handle suggested_resources with a category' do
    categorization_count = Categorization.count

    t = terms('web_of_knowledge')
    t.calculate_categorizations

    # We expect an increase because there is a Category assigned to this SuggestedResource
    assert_operator(categorization_count, :<, Categorization.count)
  end

  test 'categorization can handle suggested_resources with NO category' do
    categorization_count = Categorization.count

    t = terms('nobel_laureate')
    t.calculate_categorizations

    # We don't expect a change because there is not Category assigned to this SuggestedResource
    assert_equal(categorization_count, Categorization.count)
  end

  test 'categorization can handle suggested_patterns with a category' do
    categorization_count = Categorization.count

    t = Term.new(phrase: 'ISO 9001')
    t.calculate_categorizations

    # We expect an increase because there is a Category assigned to this SuggestedPattern
    assert_operator(categorization_count, :<, Categorization.count)
  end

  test 'categorization can handle suggested_patterns with NO category' do
    categorization_count = Categorization.count

    t = Term.new(phrase: 'ASTM 9001')
    t.calculate_categorizations

    # We don't expect a change because there is not Category assigned to this SuggestedPattern
    assert_equal(categorization_count, Categorization.count)
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

  test 'Term.fingerprint_value is a delegate of the Fingerprint method' do
    t = terms('cool')
    t.save
    t.reload

    tf = t.fingerprint

    assert_equal t.fingerprint_value, tf.value
  end

  test 'Term.fingerprint returns nil of there is no fingerprint' do
    # Terms without fingerprints are a legacy condition - fingerprints are generated when saving the term - but one that
    # we still need to confirm is stable.
    target_term = terms('hi')
    target_fingerprint = target_term.fingerprint

    assert_not_nil target_term.fingerprint

    target_fingerprint.destroy
    target_term.reload

    assert_instance_of NilClass, target_term.fingerprint
  end

  test 'Term.cluster returns empty array if no related record exists' do
    t = terms('hi')
    t.save
    t.reload

    assert_equal 1, t.fingerprint.terms.count
    assert_empty t.cluster
  end

  test 'Term.cluster returns array of terms if other terms share a fingerprint' do
    t = terms('cool')
    t.save
    t2 = terms('cool_cluster')
    t2.save
    t.reload

    assert_operator 1, :<, t.fingerprint.terms.count
    assert_instance_of Array, t.cluster
    assert_instance_of Term, t.cluster.first
    # The cluster method does not return the term itself, so the length is one less
    assert_equal t.fingerprint.terms.count - 1, t.cluster.length
  end

  test 'Term.cluster returns nil if there is no fingerprint' do
    # Setup
    target_term = terms('hi')
    target_fingerprint = target_term.fingerprint

    # Initial condition
    assert_instance_of Array, target_term.cluster

    # Delete the fingerprint, leave the term - this will only ever be a temporary condition, but one that might exist.
    target_fingerprint.destroy
    target_term.reload

    # Verify impact
    assert_nil target_term.cluster
  end

  test 'does not destroy records with suggested resource' do
    term = terms(:jstor)

    assert term.suggested_resource

    term.destroy

    assert_predicate term, :present?
  end

  test 'destroys record successfully if no suggested resource is present' do
    term = terms(:hi)
    count = Term.count

    assert_nil term.suggested_resource

    term.destroy

    assert_operator count, :-, 1, Term.count
  end

  test 'extracted features include doi' do
    term = terms('doi')
    features = term.features

    assert_nil features[:barcode]
    assert_not_nil features[:doi]
    assert_nil features[:isbn]
    assert_nil features[:issn]
    assert_nil features[:journal]
    assert_nil features[:ml_citation]
    assert_nil features[:pmid]
  end

  test 'extracted features include isbn' do
    term = terms('isbn_9781319145446')
    features = term.features

    assert_nil features[:barcode]
    assert_nil features[:doi]
    assert_not_nil features[:isbn]
    assert_nil features[:issn]
    assert_nil features[:journal]
    assert_nil features[:ml_citation]
    assert_nil features[:pmid]
  end

  test 'extracted features include issn' do
    term = terms('issn_1075_8623')
    features = term.features

    assert_nil features[:barcode]
    assert_nil features[:doi]
    assert_nil features[:isbn]
    assert_not_nil features[:issn]
    assert_nil features[:journal]
    assert_nil features[:ml_citation]
    assert_nil features[:pmid]
  end

  test 'extracted features include pmid' do
    term = terms('pmid_38908367')
    features = term.features

    assert_nil features[:barcode]
    assert_nil features[:doi]
    assert_nil features[:isbn]
    assert_nil features[:issn]
    assert_nil features[:journal]
    assert_nil features[:ml_citation]
    assert_not_nil features[:pmid]
  end

  test 'extracted features include journal' do
    term = terms('journal_nature_medicine')
    features = term.features

    assert_nil features[:barcode]
    assert_nil features[:doi]
    assert_nil features[:isbn]
    assert_nil features[:issn]
    assert_not_nil features[:journal]
    assert_nil features[:ml_citation]
    assert_nil features[:pmid]
  end

  test 'extracted features include mlcitation' do
    with_enabled_mlcitation do
      VCR.use_cassette('lambda citation') do
        term = terms('citation')
        features = term.features

        assert_nil features[:barcode]
        assert_nil features[:doi]
        assert_nil features[:isbn]
        assert_nil features[:issn]
        assert_nil features[:journal]
        assert_not_nil features[:ml_citation]
        assert_nil features[:pmid]
      end
    end
  end

  test 'extracted features include barcode' do
    term = terms('barcode')
    features = term.features

    assert_not_nil features[:barcode]
    assert_nil features[:doi]
    assert_nil features[:isbn]
    assert_nil features[:issn]
    assert_nil features[:journal]
    assert_nil features[:ml_citation]
    assert_nil features[:pmid]
  end

  test 'extracted features include citation components' do
    with_enabled_mlcitation do
      VCR.use_cassette('lambda citation all things') do
        term = terms('citation_with_all_the_things')
        features = term.features

        assert_nil features[:barcode]
        assert_not_nil features[:doi]
        assert_not_nil features[:isbn]
        assert_not_nil features[:issn]
        assert_nil features[:journal]
        assert_not_nil features[:ml_citation]
        assert_not_nil features[:pmid]

        assert_predicate features[:counts][:apa_volume_issue], :positive?
        assert_predicate features[:counts][:vol], :positive?
        assert_predicate features[:counts][:no], :positive?
        assert_predicate features[:counts][:pages], :positive?
        assert_predicate features[:counts][:pp], :positive?
        assert_predicate features[:counts][:year_parens], :positive?
        assert_predicate features[:counts][:brackets], :positive?
        assert_predicate features[:counts][:lastnames], :positive?

        assert_predicate features[:counts][:characters], :positive?
        assert_predicate features[:counts][:colons], :positive?
        assert_predicate features[:counts][:commas], :positive?
        assert_predicate features[:counts][:quotes], :positive?
        assert_predicate features[:counts][:periods], :positive?
        assert_predicate features[:counts][:semicolons], :positive?
        assert_predicate features[:counts][:words], :positive?
      end
    end
  end
end
