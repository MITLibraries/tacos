# frozen_string_literal: true

require 'test_helper'

class Detector
  class CitationTest < ActiveSupport::TestCase
    test 'detector::citation exposes three instance variables' do
      t = terms('citation')
      result = Detector::Citation.new(t)

      assert_predicate result.score, :present?

      assert_predicate result.summary, :present?

      assert_predicate result.subpatterns, :present?
    end

    test 'detector::citation generates certain summary counts always' do
      result = Detector::Citation.new(terms('hi'))
      expected = %i[characters colons commas periods semicolons words]

      assert_equal expected, result.summary.keys
    end

    test 'summary includes a character count' do
      result = Detector::Citation.new(Term.new(phrase: 'a'))

      assert_equal 1, result.summary[:characters]

      # Multibyte character
      result = Detector::Citation.new(Term.new(phrase: 'あ'))

      assert_equal 1, result.summary[:characters]

      # Twelve thousand characters? No problem...
      phrase = String.new('a' * 12_345)
      result = Detector::Citation.new(Term.new(phrase:))

      assert_equal 12_345, result.summary[:characters]
    end

    test 'summary includes a count of colons in term' do
      result = Detector::Citation.new(Term.new(phrase: 'No colons here'))

      assert_equal 0, result.summary[:colons]

      result = Detector::Citation.new(Term.new(phrase: 'Three: colons :: here'))

      assert_equal 3, result.summary[:colons]
    end

    test 'summary includes a count of commas in term' do
      result = Detector::Citation.new(Term.new(phrase: 'No commas here'))

      assert_equal 0, result.summary[:commas]

      result = Detector::Citation.new(Term.new(phrase: 'Please, buy, apples, mac, and, cheese, milk, and, bread,.'))

      assert_equal 9, result.summary[:commas]
    end

    test 'summary includes a count of periods in term' do
      result = Detector::Citation.new(Term.new(phrase: 'No periods here'))

      assert_equal 0, result.summary[:periods]

      result = Detector::Citation.new(Term.new(phrase: 'This has periods. There are two of them.'))

      assert_equal 2, result.summary[:periods]

      result = Detector::Citation.new(Term.new(phrase: 'This ends with an ellipses, which does not count, but no periods…'))

      assert_equal 0, result.summary[:periods]
    end

    test 'summary includes a count of semicolons in term' do
      result = Detector::Citation.new(Term.new(phrase: 'No semicolons here'))

      assert_equal 0, result.summary[:semicolons]

      result = Detector::Citation.new(Term.new(phrase: 'This has one semicolon;'))

      assert_equal 1, result.summary[:semicolons]

      result = Detector::Citation.new(Term.new(phrase: '&quot;HTML entities are counted&quot;'))

      assert_equal 2, result.summary[:semicolons]
    end

    test 'summary includes a word count' do
      result = Detector::Citation.new(Term.new(phrase: 'brief'))

      assert_equal 1, result.summary[:words]

      result = Detector::Citation.new(Term.new(phrase: ' extra '))

      assert_equal 1, result.summary[:words]

      result = Detector::Citation.new(Term.new(phrase: 'less  brief'))

      assert_equal 2, result.summary[:words]

      result = Detector::Citation.new(Term.new(phrase: 'hyphenated-word'))

      assert_equal 1, result.summary[:words]
    end

    test 'summary word count handles non-space separators' do
      result = Detector::Citation.new(Term.new(phrase: "tabs\tdo\tcount"))

      assert_equal 3, result.summary[:words]

      result = Detector::Citation.new(Term.new(phrase: "newlines\nalso\ncount"))

      assert_equal 3, result.summary[:words]
    end

    test 'subpatterns are empty by default' do
      result = Detector::Citation.new(Term.new(phrase: 'nothing here'))

      assert_empty(result.subpatterns)
    end

    test 'subpatterns flag all APA-style "volume(issue)" sequences' do
      result = Detector::Citation.new(Term.new(phrase: 'Weinstein, J. (2009). Classical Philology, 104(4), 439-458.'))

      assert_equal ['104(4)'], result.subpatterns[:apa_volume_issue]
    end

    test 'subpatterns flag all "no." instances with a number' do
      result = Detector::Citation.new(Term.new(phrase: 'Yes or no. vol. 6, no. 12, pp. 314'))

      assert_equal ['no. 12'], result.subpatterns[:no]
    end

    test 'subpatterns flag page ranges without spaces' do
      result = Detector::Citation.new(Term.new(phrase: 'Read from pages 1-100'))

      assert_equal ['1-100'], result.subpatterns[:pages]

      result = Detector::Citation.new(Term.new(phrase: '1 - 100'))

      assert_empty(result.subpatterns)
    end

    test 'subpatterns flag all "pp." instances with a number' do
      result = Detector::Citation.new(Term.new(phrase: 'I love this app. vol. 6, no. 12, pp. 314'))

      assert_equal ['pp. 314'], result.subpatterns[:pp]
    end

    test 'subpatterns flag all "vol." instances with a number' do
      result = Detector::Citation.new(Term.new(phrase: 'This is frivol. vol. 6, no. 12, pp. 314'))

      assert_equal ['vol. 6'], result.subpatterns[:vol]
    end

    test 'subpatterns flag all years in parentheses' do
      result = Detector::Citation.new(Term.new(phrase: 'Only two (2) four-digit years (1996) (1997) here since 2024.'))

      assert_equal ['(1996)', '(1997)'], result.subpatterns[:year_parens]
    end

    test 'subpatterns flag phrases in square brackets' do
      result = Detector::Citation.new(Term.new(phrase: 'Artificial intelligence. [Online serial].'))

      assert_equal ['[Online serial]'], result.subpatterns[:brackets]
    end

    # This is pretty rough.
    test 'subpatterns attempts to flag names as they appear in author lists' do
      result = Detector::Citation.new(Term.new(phrase: 'Sadava, D. E., D. M. Hillis, et al. Life: The Science of Biology. 11th ed. W. H. Freeman, 2016. ISBN: 9781319145446'))

      # This is also catching the last word of the title.
      assert_equal ['Sadava,', 'Hillis,', 'Biology.', 'Freeman,'], result.subpatterns[:lastnames]
    end

    test 'subpatterns flag phrases in quotes' do
      result = Detector::Citation.new(Term.new(phrase: '&quot;Principles of Materials Science and Engineering&quot; by William F. Smith and Javad Hashemi'))

      assert_equal ['&quot;Principles of Materials Science and Engineering&quot;'], result.subpatterns[:quotes]

      # Need two to catch anything
      result = Detector::Citation.new(Term.new(phrase: 'Principles of Materials Science and Engineering&quot; by William F. Smith and Javad Hashemi'))

      assert_empty(result.subpatterns)
    end

    test 'citation score increases as phrase gets more citation-like' do
      result = Detector::Citation.new(Term.new(phrase: 'simple search phrase'))

      assert_equal 0, result.score

      result = Detector::Citation.new(Term.new(phrase: 'Science Education and Cultural Diversity: Mapping the Field. Studies in Science Education, 24(1), 49–73.'))

      assert_operator 0, :<, result.score
    end

    test 'record method does relevant work' do
      detection_count = Detection.count
      t = terms('citation')

      Detector::Citation.record(t)

      assert_equal detection_count + 1, Detection.count
    end

    test 'record method does nothing when not needed' do
      detection_count = Detection.count
      t = terms('hi')

      Detector::Citation.record(t)

      assert_equal detection_count, Detection.count
    end

    test 'record method respects changes to the DETECTOR_VERSION value' do
      # Create a relevant detection
      t = terms('citation')
      Detector::Citation.record(t)

      detection_count = Detection.count

      # Calling the record method again doesn't do anything, but does not error.
      Detector::Citation.record(t)

      assert_equal detection_count, Detection.count

      # Calling the record method after DETECTOR_VERSION is incremented results in a new Detection.
      ClimateControl.modify DETECTOR_VERSION: 'updated' do
        Detector::Citation.record(t)

        assert_equal detection_count + 1, Detection.count
      end
    end
  end
end
