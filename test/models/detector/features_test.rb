# frozen_string_literal: true

require 'test_helper'

class Detector
  class FeaturesTest < ActiveSupport::TestCase
    test 'detector::features exposes three instance variables' do
      t = terms('citation')
      result = Detector::Features.new(t.phrase)

      assert_predicate result.features, :present?

      assert_predicate result.summary, :present?

      assert_predicate result.patterns, :present?
    end

    test 'detector::features generates certain summary counts always' do
      result = Detector::Features.new(terms('hi').phrase)
      expected = %i[characters colons commas periods semicolons words]

      assert_equal expected, result.summary.keys
    end

    test 'summary includes a character count' do
      result = Detector::Features.new('a')

      assert_equal 1, result.summary[:characters]

      # Multibyte character
      result = Detector::Features.new('あ')

      assert_equal 1, result.summary[:characters]

      # Twelve thousand characters? No problem...
      phrase = String.new('a' * 12_345)
      result = Detector::Features.new(phrase)

      assert_equal 12_345, result.summary[:characters]
    end

    test 'summary includes a count of colons in term' do
      result = Detector::Features.new('No colons here')

      assert_equal 0, result.summary[:colons]

      result = Detector::Features.new('Three: colons :: here')

      assert_equal 3, result.summary[:colons]
    end

    test 'summary includes a count of commas in term' do
      result = Detector::Features.new('No commas here')

      assert_equal 0, result.summary[:commas]

      result = Detector::Features.new('Please, buy, apples, mac, and, cheese, milk, and, bread,.')

      assert_equal 9, result.summary[:commas]
    end

    test 'summary includes a count of periods in term' do
      result = Detector::Features.new('No periods here')

      assert_equal 0, result.summary[:periods]

      result = Detector::Features.new('This has periods. There are two of them.')

      assert_equal 2, result.summary[:periods]

      result = Detector::Features.new('This ends with an ellipses, which does not count, but no periods…')

      assert_equal 0, result.summary[:periods]
    end

    test 'summary includes a count of semicolons in term' do
      result = Detector::Features.new('No semicolons here')

      assert_equal 0, result.summary[:semicolons]

      result = Detector::Features.new('This has one semicolon;')

      assert_equal 1, result.summary[:semicolons]

      result = Detector::Features.new('&quot;HTML entities are counted&quot;')

      assert_equal 2, result.summary[:semicolons]
    end

    test 'summary includes a word count' do
      result = Detector::Features.new('brief')

      assert_equal 1, result.summary[:words]

      result = Detector::Features.new(' extra ')

      assert_equal 1, result.summary[:words]

      result = Detector::Features.new('less  brief')

      assert_equal 2, result.summary[:words]

      result = Detector::Features.new('hyphenated-word')

      assert_equal 1, result.summary[:words]
    end

    test 'summary word count handles non-space separators' do
      result = Detector::Features.new("tabs\tdo\tcount")

      assert_equal 3, result.summary[:words]

      result = Detector::Features.new("newlines\nalso\ncount")

      assert_equal 3, result.summary[:words]
    end

    test 'patterns are empty by default' do
      result = Detector::Features.new('nothing here')

      assert_empty(result.patterns)
    end

    test 'patterns flag all APA-style "volume(issue)" sequences' do
      result = Detector::Features.new('Weinstein, J. (2009). Classical Philology, 104(4), 439-458.')

      assert_equal ['104(4)'], result.patterns[:apa_volume_issue]
    end

    test 'patterns flag all "no." instances with a number' do
      result = Detector::Features.new('Yes or no. vol. 6, no. 12, pp. 314')

      assert_equal ['no. 12'], result.patterns[:no]
    end

    test 'patterns flag page ranges without spaces' do
      result = Detector::Features.new('Read from pages 1-100')

      assert_equal ['1-100'], result.patterns[:pages]

      result = Detector::Features.new('1 - 100')

      assert_empty(result.patterns)
    end

    test 'patterns flag all "pp." instances with a number' do
      result = Detector::Features.new('I love this app. vol. 6, no. 12, pp. 314')

      assert_equal ['pp. 314'], result.patterns[:pp]
    end

    test 'patterns flag all "vol." instances with a number' do
      result = Detector::Features.new('This is frivol. vol. 6, no. 12, pp. 314')

      assert_equal ['vol. 6'], result.patterns[:vol]
    end

    test 'patterns flag all years in parentheses' do
      result = Detector::Features.new('Only two (2) four-digit years (1996) (1997) here since 2024.')

      assert_equal ['(1996)', '(1997)'], result.patterns[:year_parens]
    end

    test 'patterns flag phrases in square brackets' do
      result = Detector::Features.new('Artificial intelligence. [Online serial].')

      assert_equal ['[Online serial]'], result.patterns[:brackets]
    end

    # This is pretty rough.
    test 'patterns attempts to flag names as they appear in author lists' do
      result = Detector::Features.new('Sadava, D. E., D. M. Hillis, et al. Life: The Science of Biology. 11th ed. W. H. Freeman, 2016. ISBN: 9781319145446')

      # This is also catching the last word of the title.
      assert_equal ['Sadava,', 'Hillis,', 'Biology.', 'Freeman,'], result.patterns[:lastnames]
    end

    test 'patterns flag phrases in quotes' do
      result = Detector::Features.new('&quot;Principles of Materials Science and Engineering&quot; by William F. Smith and Javad Hashemi')

      assert_equal ['&quot;Principles of Materials Science and Engineering&quot;'], result.patterns[:quotes]

      # Need two to catch anything
      result = Detector::Features.new('Principles of Materials Science and Engineering&quot; by William F. Smith and Javad Hashemi')

      assert_empty(result.patterns)
    end

    test 'features instance method is a hash of integers' do
      result = Detector::Features.new('simple search phrase')

      assert_instance_of(Hash, result.features)

      assert(result.features.all? { |_, v| v.integer? })
    end

    test 'features instance method includes all elements of citation detector regardless of search string' do
      result_simple = Detector::Features.new('simple')
      result_complex = Detector::Features.new('Science Education and Cultural Diversity: Mapping the Field. Studies in Science Education, 24(1), 49–73.')

      assert_equal result_simple.features.length, result_complex.features.length
    end

    test 'features instance method should include all elements of citation patterns and summary thresholds' do
      patterns = Detector::Features.const_get :CITATION_PATTERNS
      result = Detector::Features.new('simple')

      assert_equal (patterns.length + result.summary.length), result.features.length
    end
  end
end
