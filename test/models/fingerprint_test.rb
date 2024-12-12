# frozen_string_literal: true

# == Schema Information
#
# Table name: fingerprints
#
#  id          :integer          not null, primary key
#  fingerprint :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'test_helper'

class FingerprintTest < ActiveSupport::TestCase
  test 'duplicate term fingerprints are not allowed' do
    tf = Fingerprint.first

    assert_raises(ActiveRecord::RecordInvalid) do
      Fingerprint.create!(fingerprint: tf.fingerprint)
    end
  end

  test 'deleting a Fingerprint does not delete its Term, which is still valid' do
    # Setup
    target_term = Term.last
    target_term.save
    target_term.reload
    target = target_term.fingerprint

    # Initial condition
    term_count = Term.count
    fingerprint_count = Fingerprint.count

    assert_operator 0, :<, target.terms.count

    # Change
    target.destroy
    target_term.reload

    # Verify impact
    assert_equal term_count, Term.count
    assert_equal fingerprint_count - 1, Fingerprint.count
    assert_nil target_term.fingerprint_value
    assert_predicate target_term, :valid?
  end

  # These tests appear in order of operation within the calculate method.
  test 'fingerprints strip excess spaces' do
    example = '  i  need  space   '

    assert_equal 'i need space', Fingerprint.calculate(example)
  end

  test 'fingerprints are coerced to lower case' do
    example = 'InterCapping FTW'

    assert_equal 'ftw intercapping', Fingerprint.calculate(example)
  end

  test 'fingerprints strip out &quot;' do
    example = '&quot;in quotes&quot;'

    assert_equal 'in quotes', Fingerprint.calculate(example)
  end

  test 'fingerprints remove punctuation and symbols' do
    example = 'symbols™ + punctuation: * bullets! - "quoted phrase" (perfect) ¥€$'

    assert_equal 'bullets perfect phrase punctuation quoted symbols', Fingerprint.calculate(example)
  end

  test 'fingerprints coerce characters to ASCII' do
    example = 'а а̀ а̂ а̄ ӓ б в г ґ д ђ ѓ е ѐ е̄ е̂ ё є ж з з́ ѕ и і ї ꙇ ѝ и̂ ӣ й ј к л љ м н њ о о̀ о̂ ō ӧ п р с с́ ' \
              'т ћ ќ у у̀ у̂ ӯ ў ӱ ф х ц ч џ ш щ ꙏ ъ ъ̀ ы ь ѣ э ю ю̀ я'

    assert_equal 'a b ch d dj dz dzh e f g gh gj i ia ie io iu j k kh kj l lj m n nj o p r s ' \
                 'sh shch t ts tsh u v y yi z zh', Fingerprint.calculate(example)
  end

  test 'fingerprints remove repeated words' do
    example = 'double double'

    assert_equal 'double', Fingerprint.calculate(example)
  end

  test 'fingerprints list words in alphabetical order' do
    example = 'delta beta gamma alpha'

    assert_equal 'alpha beta delta gamma', Fingerprint.calculate(example)
  end
end
