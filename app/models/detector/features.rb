# frozen_string_literal: true

class Detector
  class Features
    attr_reader :features, :patterns, :summary

    # Citation patterns are regular expressions which attempt to identify structures that are part of many citations.
    # This object is used as part of the pattern_checker method. Some of these patterns may get promoted to the Detector
    # model if they prove useful beyond a Citation context.
    CITATION_PATTERNS = {
      apa_volume_issue: /\d+\(\d+\)/,
      no: /no\.\s\d+/,
      pages: /\d+-+\d+/,
      pp: /pp\.\s\d+/,
      vol: /vol\.\s\d+/,
      year_parens: /\(\d{4}\)/,
      brackets: /\[.*?\]/,
      lastnames: /[A-Z][a-z]+[.,]/,
      quotes: /&quot;.*?&quot;/
    }.freeze

    def initialize(phrase)
      @features = {}
      @patterns = {}
      @summary = {}
      pattern_checker(phrase)
      summarize(phrase)
      @features = @patterns.deep_dup.transform_values(&:length).merge(summary)
      @patterns.delete_if { |_, v| v == [] }
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

    # This builds one of the two main components of the Citation detector - the subpattern report. It uses each of the
    # regular expressions in the CITATION_PATTERNS constant, extracting all matches using the scan method.
    #
    # @return hash
    def pattern_checker(phrase)
      CITATION_PATTERNS.each_pair do |type, pattern|
        @patterns[type.to_sym] = scan(pattern, phrase)
      end
    end

    # This counts the number of periods in the search phrase. It is called by the summarize method.
    def periods(phrase)
      phrase.count('.')
    end

    # This is a convenience method for the scan method, which is used by pattern_checker.
    def scan(pattern, phrase)
      phrase.scan(pattern).map(&:strip)
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
