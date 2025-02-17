# frozen_string_literal: true

# PreprocessorPrimo handles manipulating incoming data from the Primo UI into a structure that TACOS can work with
class PreprocessorPrimo
  # to_tacos processes raw incoming query from Primo, looks at each part to see if it is a keyword anywhere search
  # Any portion that is not a keyword anywhere search drops the entire search from TACOS, logging
  # as the shared Term `unhandled complex primo query` to allow us to track how frequently we are
  # dropping terms so we can come back later to build out more complex handing if this is common enough
  # to warrant the additional work.
  # @param query [String] example `any,contains,this is a keyword search`
  def self.to_tacos(query)
    # Primo and TACOS agreed upon joiner is `;;;`
    split_query = query.split(';;;')

    if split_query.count > 1
      Rails.logger.debug('Multipart primo query detected')

      # As we are not currently handling complex queries, always set the value to something we can track frequency of
      'unhandled complex primo query'
    else
      Rails.logger.debug('Simple primo query detected')

      extract_keyword(query)
    end
  end

  # keyword? confirms whether a portion of a primo query is a keyword search
  # Note: we expect only 3 elements to this array for simple keyword searches and that arrays created from the Primo
  # input to be collapsed so commas in the original search have been handled via the comma_handler method
  # @param query_part_array [Array] example ['any', 'contains', 'this is a keyword search']
  # @return [Boolean]
  def self.keyword?(query_part_array)
    return false unless query_part_array.count == 3
    return false unless query_part_array[0] == 'any'

    # For now, we are allowing all variants of the second portion of the primo query input
    # The expected values are: contains, exact, begins_with, equals
    # Uncommenting the following statement would allow us to restrict to just the default 'contains' if desireable
    #
    # return false unless query_part_array[1] == 'contains'

    true
  end

  # extract_keyword works at the level of a single keyword query input coming from primo and
  # returns a string with just that keyword with the operators removed
  # @param query_part [String] example `any,contains,this is a keyword search`
  # @return [String] the extracted keyword phrase
  def self.extract_keyword(query_part)
    query_part_array = query_part.split(',')

    # We don't anticipate this being a normal state so we are tracking it under the Term `invalid primo query` as well
    # as sending an exception to Sentry so we can understand the context in which this happens if it does
    if query_part_array.count < 3
      Sentry.capture_message('PreprocessorPrimo: Invalid Primo query during keyword extraction')
      return 'invalid primo query'
    end

    the_keywords = join_keyword_and_drop_extra_parts(query_part_array)

    return 'unhandled complex primo query' unless keyword?([query_part_array[0], query_part_array[1], the_keywords])

    the_keywords
  end

  # join_keyword_and_drop_extra_parts handles the logic necessary to join searches that contain commas into a single ruby string
  # after we separate the incoming string into an array based on commas
  # @param query_part [String] example `['any', 'contains', 'this', 'is', 'a', 'keyword', 'search']`
  # @return [String] example 'this,is,a,keyword,search'
  def self.join_keyword_and_drop_extra_parts(query_part_array)
    # For complex queries, which we are not handling yet, we'll need to determine how TACOS should handle the final
    # element of the input which will be a boolean operator. For now, we will have stopped processing those by this
    # point during the initial logic in `to_tacos` that splits on `;;` and returns if the result is more than one query
    query_part_array.slice(2..).join(',')
  end
end
