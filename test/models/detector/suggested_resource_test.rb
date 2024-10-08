# frozen_string_literal: true

# == Schema Information
#
# Table name: detector_suggested_resources
#
#  id          :integer          not null, primary key
#  title       :string
#  url         :string
#  phrase      :string
#  fingerprint :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require 'test_helper'

class Detector
  class SuggestedResourceTest < ActiveSupport::TestCase
    test 'fingerprints are generated automatically' do
      resource = {
        title: 'Our latest resource',
        url: 'https://example.org',
        phrase: 'Our latest resource'
      }

      new_resource = Detector::SuggestedResource.create(resource)

      assert_equal 'latest our resource', new_resource.fingerprint
    end

    test 'fingerprints are recalculated on save' do
      resource = detector_suggested_resources('jstor')

      assert_not_equal resource.fingerprint, 'A brand new phrase'

      resource.phrase = 'This is a brand new phrase'
      resource.save
      resource.reload

      assert_equal 'a brand is new phrase this', resource.fingerprint
    end

    test 'generating fingerprints does not alter the phrase' do
      resource = detector_suggested_resources('jstor')
      benchmark = 'This is an updated phrase! '

      assert_not_equal resource.phrase, benchmark
      resource.phrase = benchmark
      resource.save
      resource.reload

      assert_equal resource.phrase, benchmark
    end

    test 'fingerprints strip extra spaces' do
      resource = detector_suggested_resources('jstor')

      assert_not_equal resource.fingerprint, 'i need space'

      resource.phrase = '  i  need  space  '
      resource.save
      resource.reload

      assert_equal 'i need space', resource.fingerprint
    end

    test 'fingerprints are coerced to lowercase' do
      resource = detector_suggested_resources('jstor')

      assert_not_equal resource.fingerprint, 'ftw intercapping'

      resource.phrase = 'InterCapping FTW'
      resource.save
      resource.reload

      assert_equal 'ftw intercapping', resource.fingerprint
    end

    test 'fingerprints remove punctuation and symbols' do
      resource = detector_suggested_resources('jstor')

      assert_not_equal resource.fingerprint, 'bullets perfect phrase punctuation quoted symbols'

      resource.phrase = 'symbols™ + punctuation: * bullets! - "quoted phrase" (perfect) ¥€$'
      resource.save
      resource.reload

      assert_equal 'bullets perfect phrase punctuation quoted symbols', resource.fingerprint
    end

    test 'fingerprints coerce characters to ASCII' do
      resource = {
        title: 'A wide range of characters',
        url: 'https://example.org',
        phrase: 'а а̀ а̂ а̄ ӓ б в г ґ д ђ ѓ е ѐ е̄ е̂ ё є ж з з́ ѕ и і ї ꙇ ѝ и̂ ӣ й ј к л љ м н њ о о̀ о̂ ō ӧ п р с с́ ' \
                'т ћ ќ у у̀ у̂ ӯ ў ӱ ф х ц ч џ ш щ ꙏ ъ ъ̀ ы ь ѣ э ю ю̀ я'
      }

      new_resource = Detector::SuggestedResource.create(resource)

      assert_equal 'a b ch d dj dz dzh e f g gh gj i ia ie io iu j k kh kj l lj m n nj o p r s ' \
                   'sh shch t ts tsh u v y yi z zh', new_resource.fingerprint
    end

    test 'fingerprints remove repeated words' do
      resource = detector_suggested_resources('jstor')

      assert_not_equal resource.fingerprint, 'double'

      resource.phrase = 'double double'
      resource.save
      resource.reload

      assert_equal 'double', resource.fingerprint
    end

    test 'fingerprints sort words alphabetically' do
      resource = detector_suggested_resources('jstor')

      assert_not_equal resource.fingerprint, 'delta gamma'

      resource.phrase = 'gamma delta'
      resource.save
      resource.reload

      assert_equal 'delta gamma', resource.fingerprint
    end

    test 'fingerprint matches on search term' do
      expected = detector_suggested_resources('jstor')
      actual = Detector::SuggestedResource.full_term_match('jstor')

      assert_equal 1, actual.count
      assert_equal expected, actual.first
    end

    test 'fingerprint matches on any word order or punctuation' do
      expected = detector_suggested_resources('nobel_laureate')
      actual_one = Detector::SuggestedResource.full_term_match('Moungi Bawendi')
      actual_two = Detector::SuggestedResource.full_term_match('Bawendi, Moungi')

      assert_equal 1, actual_one.count
      assert_equal expected, actual_one.first
      assert_equal actual_one.first, actual_two.first
    end

    test 'partial fingerprint matches do not count' do
      actual_partial = Detector::SuggestedResource.full_term_match('science web')
      actual_extra = Detector::SuggestedResource.full_term_match('the web of science')

      assert_predicate actual_partial.count, :zero?
      assert_predicate actual_extra.count, :zero?
    end

    test 'record does relevant work' do
      detection_count = Detection.count
      t = terms('suggested_resource_jstor')

      Detector::SuggestedResource.record(t)

      assert_equal(detection_count + 1, Detection.count)
    end

    test 'record does nothing when not needed' do
      detection_count = Detection.count
      t = terms('isbn_9781319145446')

      Detector::SuggestedResource.record(t)

      assert_equal(detection_count, Detection.count)
    end

    test 'record respects changes to the DETECTOR_VERSION value' do
      # Create a relevant detection
      Detector::SuggestedResource.record(terms('suggested_resource_jstor'))

      detection_count = Detection.count

      # Calling the record method again doesn't do anything, but does not error.
      Detector::SuggestedResource.record(terms('suggested_resource_jstor'))

      assert_equal(detection_count, Detection.count)

      # Calling the record method after DETECTOR_VERSION is incremented results in a new Detection
      ClimateControl.modify DETECTOR_VERSION: 'updated' do
        Detector::SuggestedResource.record(terms('suggested_resource_jstor'))

        assert_equal detection_count + 1, Detection.count
      end
    end
  end
end
