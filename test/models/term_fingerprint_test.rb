# frozen_string_literal: true

# == Schema Information
#
# Table name: term_fingerprints
#
#  id          :integer          not null, primary key
#  fingerprint :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'test_helper'

class TermFingerprintTest < ActiveSupport::TestCase
  test 'duplicate term fingerprints are not allowed' do
    tf = TermFingerprint.first

    assert_raises(ActiveRecord::RecordInvalid) do
      TermFingerprint.create!(fingerprint: tf.fingerprint)
    end
  end

  test 'deleting a TermFingerprint does not delete its Term, which is still valid' do
    term_count = Term.count
    fingerprint_count = TermFingerprint.count

    target = TermFingerprint.last
    target_term = target.terms.last

    assert_operator 0, :<, target.terms.count

    target.destroy
    target_term.reload

    assert_equal term_count, Term.count
    assert_equal fingerprint_count - 1, TermFingerprint.count
    assert_instance_of NilClass, target_term.term_fingerprint
    assert_predicate target_term, :valid?
  end
end
