# frozen_string_literal: true

require 'test_helper'

class Detector
  class CitationTest < ActiveSupport::TestCase
    test 'citation_bulk_checker' do
      bulk = Detector::Citation.check_all_matches(output: true)

      assert_equal(2, bulk.count)
    end

    test 'journal_bulk_checker' do
      bulk = Detector::Journal.check_all_matches(output: true)

      assert_equal(1, bulk.count)
    end

    test 'lcsh_bulk_checker' do
      bulk = Detector::Lcsh.check_all_matches(output: true)

      assert_equal(1, bulk.count)
    end

    test 'standard_identifier_bulk_checker' do
      bulk = Detector::StandardIdentifiers.check_all_matches(output: true)

      assert_equal(7, bulk.count)
    end

    test 'suggested_resources_bulk_checker' do
      skip 'Detector::SuggestedResources does not yet support bulk_checker'
    end
  end
end
