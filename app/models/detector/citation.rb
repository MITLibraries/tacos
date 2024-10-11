# frozen_string_literal: true

class Detector
  # Detector::Citation attempts to identify citations based on the prevalence of individual sub-patterns. It is not
  # targeted at a particular citation format, but was designed based on characteristics of five formats: APA, MLA,
  # Chicago, Terabian, and IEEE.
  #
  # It receives a Term object, which is parsed in various ways en route to calculating a final score. Terms with a
  # higher score are more citation-like, while a score of 0 indicates a Term that has no hallmarks of being a citation.
  # Terms whose score is higher than the REQUIRED_SCORE value can be registered as a Detection.
  class Citation
    attr_reader :score, :subpatterns, :summary

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

    # The required score value is the threshold needed for a Term to be officially recorded with a Detection.
    REQUIRED_SCORE = 6

    # Summary thresholds are used by the calculate_score method. This class counts the number of occurrences of specific
    # characters in the @summary instance variable. The thresholds here determine whether any of those counts are high
    # enough to contribute to the Term's citation score.
    SUMMARY_THRESHOLDS = {
      characters: 25,
      colons: 2,
      commas: 2,
      periods: 2,
      semicolons: 2,
      words: 5
    }.freeze

    # Detection? is a convenience method to check whether the calculated @score is high enough to qualify as a citation.
    #
    # @return boolean
    def detection?
      @score >= REQUIRED_SCORE
    end

    # The initializer handles the parsing of a Term object, and subsequent population of the @subpatterns, @summary,
    # and @score instance variables. @subpatterns contains all the citation components which have been flagged by the
    # CITATION_PATTERNS hash. @summary contains counts of how often certain characters or words appear in the Term.
    # Finally, the @score value is a summary of how many elements in the subpatterns or summary report were detected.
    #
    # @note This method can be called directly via Detector::Citation.new(Term). It is also called indirectly via the
    #       Detector::Citation.record(Term) instance method. This method can be called directly when a Detection is not
    #       desired.
    def initialize(term)
      @subpatterns = {}
      @summary = {}
      pattern_checker(term.phrase)
      summarize(term.phrase)
      @score = calculate_score
    end

    # The record method first runs all of the parsers by running the initialize method. If the resulting score is higher
    # than the REQUIRED_SCORE value, then a Detection is registered.
    #
    # @return nil
    def self.record(term)
      cit = Detector::Citation.new(term)
      return unless cit.detection?

      Detection.find_or_create_by(
        term:,
        detector: Detector.where(name: 'Citation').first,
        detector_version: ENV.fetch('DETECTOR_VERSION', 'unset')
      )

      nil
    end

    private

    # This combines the two reports generated by the Citation detector (subpatterns and summary), and calculates the
    # final score value from their contents.
    #
    # Any detected subpattern is counted toward the score (multiple detections do not get counted twice). For example,
    # if the brackets pattern finds two matches, it still only adds one to the final score.
    #
    # For the summary report, each value is compared with a threshold value in the SUMMARY_THRESHOLDS constant. The
    # number of values which meet or exceed their threshold are added to the score. As an example, if a search term has
    # five words, this value is compared to the word threshold (also five). Because the threshold is met, the score gets
    # incremented by one.
    #
    # @return integer
    def calculate_score
      summary_score = @summary.count do |key, value|
        SUMMARY_THRESHOLDS.key?(key) && value >= SUMMARY_THRESHOLDS[key]
      end

      summary_score + @subpatterns.length
    end

    # This calculates the number of characters in the search term. It is called by the summarize method.
    def characters(term)
      term.length
    end

    # This counts the number of colons that appear in the search term, because they tend to appear more often in
    # citations than in other searches. It is called by the summarize method.
    def colons(term)
      term.count(':')
    end

    # This counts the number of commas in the search term. It is called by the summarize method.
    def commas(term)
      term.count(',')
    end

    # This builds one of the two main components of the Citation detector - the subpattern report. It uses each of the
    # regular expressions in the CITATION_PATTERNS constant, extracting all matches using the scan method.
    #
    # @return hash
    def pattern_checker(term)
      CITATION_PATTERNS.each_pair do |type, pattern|
        @subpatterns[type.to_sym] = scan(pattern, term) if scan(pattern, term).present?
      end
    end

    # This counts the number of periods in the search term. It is called by the summarize method.
    def periods(term)
      term.count('.')
    end

    # This is a convenience method for the scan method, which is used by pattern_checker.
    def scan(pattern, term)
      term.scan(pattern).map(&:strip)
    end

    # This counts the semicolons in the search term. It is called by the summarize method.
    def semicolons(term)
      term.count(';')
    end

    # This builds one of the two main components of the Citation detector - the summary report. It calls each of the
    # methods in the first line - which all return integers - and puts the result as a key-value pair in the @summary
    # instance variable.
    #
    # @return hash
    def summarize(term)
      %w[characters colons commas periods semicolons words].each do |check|
        @summary[check.to_sym] = send(check, term)
      end
    end

    # This counts the number of words in the search term. It is called by the summarize method.
    def words(term)
      term.split.length
    end
  end
end
