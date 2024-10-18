# frozen_string_literal: true

require 'test_helper'

class Detector
  class CitationTest < ActiveSupport::TestCase
    test 'citation_bulk_checker' do
      bulk = Detector::Citation.check_all_matches
      assert_equal(bulk.count, 2)
    end

    test 'journal_bulk_checker' do
      skip 'Detector::Journal does not yet support bulk_checker'
    end

    test 'lcsh_bulk_checker' do
      bulk = Detector::Lcsh.check_all_matches
      assert_equal(bulk.count, 1)
    end

    test 'standard_identifier_bulk_checker' do
      bulk = Detector::StandardIdentifiers.check_all_matches
      assert_equal(bulk.count, 5)
    end

    test 'suggested_resources_bulk_checker' do
      skip 'Detector::SuggestedResources does not yet support bulk_checker'
    end
  end
end
