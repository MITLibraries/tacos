# frozen_string_literal: true

# PreprocessorPrimo handles manipulating incoming data from the Primo UI into a structure that TACOS can work with
class PreprocessorPrimo
  # Processes raw incoming query from Primo, looks at each part to see if it is a keyword anywhere search
  # Any portion that is not a keyword anywhere search drops the entire search from TACOS, logging
  # as the shared Term `unhandled complex primo query` to allow us to track how frequently we are
  # dropping terms so we can come back later to build out more complex handing if this is common enough
  # to warrant the additional work
  def self.to_tacos(query)
    # split on agreed upon joiner `;;`
    split_query = query.split(';;')
    # if more than one
    if split_query.count > 1
      Rails.logger.debug('Multipart primo query detected')

      # parts = []
      # split_query.each do |q|
      #   parts << extract_keyword(q)
      # end

      # drop anything that isn't `any,contains` as TACOS does not process those yet
      # return 'unhandled complex primo query' if parts.any?('unhandled complex primo query')

      # combine what is left
      # parts.join(' ')
      'unhandled complex primo query'
    else
      Rails.logger.debug('Simple primo query detected')
      # confirm it is `any,contains`

      extract_keyword(query)
    end
  end

  # confirms whether a portion of a primo query is a keyword search
  # @param [Array] query_part_array
  def self.keyword?(query_part_array)
    return false unless query_part_array.count >= 3
    return false unless query_part_array[0] == 'any'

    # For now, we are allowing all variants of the second portion of the primo query input
    # The expected values are: contains, exact, begins_with, equals
    #
    # return false unless query_part_array[1] == 'contains'

    true
  end

  # extract keyword work at the level of a single keyword query input coming from primo and
  # returns a string with just that keyword with the operators removed
  # @param [String] query_part
  # @return [String] the extracted keyword phrase
  def self.extract_keyword(query_part)
    query_part_array = query_part.split(',')

    return 'unhandled complex primo query' unless keyword?(query_part_array)

    query_part_array.slice(2..).join(',')
  end
end
