# frozen_string_literal: true

#
require 'test_helper'

class PreprocessorPrimoTest < ActiveSupport::TestCase
  test 'to_tacos returns unhandled for complex queries' do
    input = 'any,contains,space;;;any,contains,madness'

    assert_equal('unhandled complex primo query', PreprocessorPrimo.to_tacos(input))
  end

  test 'to_tacos returns unhandled for targeted field queries' do
    input = 'title,contains,space'

    assert_equal('unhandled complex primo query', PreprocessorPrimo.to_tacos(input))
  end

  test 'to_tacos returns phrase ready for tacos for simple keyword input' do
    input = 'any,contains,space'

    assert_equal('space', PreprocessorPrimo.to_tacos(input))
  end

  test 'to_tacos returns phrase ready for complex keyword input' do
    input = 'any,contains,Yan, F., Krantz, P., Sung, Y., Kjaergaard, M., Campbell, D.L., Orlando, T.P., Gustavsson, S. and Oliver, W.D., 2018. Tunable coupling scheme for implementing high-fidelity two-qubit gates. Physical Review Applied, 10(5), p.054062.'
    expected = 'Yan, F., Krantz, P., Sung, Y., Kjaergaard, M., Campbell, D.L., Orlando, T.P., Gustavsson, S. and Oliver, W.D., 2018. Tunable coupling scheme for implementing high-fidelity two-qubit gates. Physical Review Applied, 10(5), p.054062.'

    assert_equal(expected, PreprocessorPrimo.to_tacos(input))
  end

  test 'keyword? returns true for any contains phrase pattern' do
    input = 'any,contains,popcorn anomoly'.split(',')

    assert(PreprocessorPrimo.keyword?(input))
  end

  test 'keyword? returns false for input with more than 3 array elements' do
    # NOTE: this query entering tacos would work... but it would have been cleaned up prior to running
    # keyword? in our application via the normal flow
    input = 'any,contains,popcorn anomoly: why life on the moon is complex, and other cat facts'.split(',')

    assert_not(PreprocessorPrimo.keyword?(input))
  end

  test 'keyword? returns false for input with less than 3 array elements' do
    input = 'any,contains'.split(',')

    assert_not(PreprocessorPrimo.keyword?(input))
  end

  test 'keyword? returns false for non-any input' do
    input = 'title,contains,popcorn anomoly'.split(',')

    assert_not(PreprocessorPrimo.keyword?(input))
  end

  test 'keyword? returns true for non-contains inputs' do
    # NOTE: this portion of they primo query focuses on how to handle the phrase. All the words, any of the words,
    # the exact phrase, begins_with. For now we treat them all the same as standard keyword queries.
    input = 'any,exact,popcorn anomoly'.split(',')

    assert(PreprocessorPrimo.keyword?(input))
  end

  test 'extract keyword returns keyword for simple keywords' do
    input = 'any,contains,popcorn anomoly'

    assert_equal('popcorn anomoly', PreprocessorPrimo.extract_keyword(input))
  end

  test 'extract keyword returns keyword for simple non-contains keywords' do
    input = 'any,exact,popcorn anomoly'

    assert_equal('popcorn anomoly', PreprocessorPrimo.extract_keyword(input))
  end

  test 'extract keyword returns unhandled complex primo query for non-any searches' do
    input = 'title,contains,popcorn anomoly'

    assert_equal('unhandled complex primo query', PreprocessorPrimo.extract_keyword(input))
  end

  test 'extract keyword returns keyword for keywords with punctuation' do
    input = 'any,contains,popcorn anomoly: a cats! life. on & mars!'

    assert_equal('popcorn anomoly: a cats! life. on & mars!', PreprocessorPrimo.extract_keyword(input))
  end

  test 'extract keyword returns keyword for keywords with commas' do
    input = 'any,contains,popcorn anomoly, and so can you'

    assert_equal('popcorn anomoly, and so can you', PreprocessorPrimo.extract_keyword(input))
  end

  test 'extract keyword returns keyword for keywords with multiple commas and other punctuation' do
    input = 'any,contains,popcorn anomoly: a cats! life. on & mars!, words, of {truth} (and, also not,)'

    assert_equal('popcorn anomoly: a cats! life. on & mars!, words, of {truth} (and, also not,)',
                 PreprocessorPrimo.extract_keyword(input))
  end
end
