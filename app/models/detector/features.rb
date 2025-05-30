# frozen_string_literal: true

class Detector
  class Features
    attr_reader :summary

    def initialize(phrase)
      @summary = {}
      summarize(phrase)
    end

    private

    # This calculates the number of characters in the search phrase. It is called by the summarize method.
    def characters(phrase)
      phrase.length
    end

    # This counts the number of colons that appear in the search phrase, because they tend to appear more often in
    # citations than in other searches. It is called by the summarize method.
    def colons(phrase)
      phrase.count(':')
    end

    # This counts the number of commas in the search phrase. It is called by the summarize method.
    def commas(phrase)
      phrase.count(',')
    end

    # This counts the number of periods in the search phrase. It is called by the summarize method.
    def periods(phrase)
      phrase.count('.')
    end

    # This counts the semicolons in the search phrase. It is called by the summarize method.
    def semicolons(phrase)
      phrase.count(';')
    end

    # This builds one of the two main components of the Citation detector - the summary report. It calls each of the
    # methods in the first line - which all return integers - and puts the result as a key-value pair in the @summary
    # instance variable.
    #
    # @return hash
    def summarize(phrase)
      %w[characters colons commas periods semicolons words].each do |check|
        @summary[check.to_sym] = send(check, phrase)
      end
    end

    # This counts the number of words in the search phrase. It is called by the summarize method.
    def words(phrase)
      phrase.split.length
    end
  end
end
