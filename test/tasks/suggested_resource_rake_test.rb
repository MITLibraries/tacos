# frozen_string_literal: true

require 'test_helper'
require 'rake'

class SuggestedResourceRakeTest < ActiveSupport::TestCase
  def setup
    Tacos::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['suggested_resources:reload'].reenable
  end

  test 'reload can accept a url' do
    records_before = Detector::SuggestedResource.count # We have three fixtures at the moment
    first_record_before = Detector::SuggestedResource.first
    VCR.use_cassette('suggested_resource:reload from remote csv') do
      remote_file = 'http://static.lndo.site/suggested_resources.csv'
      Rake::Task['suggested_resources:reload'].invoke(remote_file)
    end
    refute_equal records_before, Detector::SuggestedResource.count
    refute_equal first_record_before, Detector::SuggestedResource.first
  end

  test 'reload task errors without a file argument' do
    error = assert_raises(ArgumentError) do
      Rake::Task['suggested_resources:reload'].invoke
    end
    assert_equal 'URL is required', error.message
  end

  test 'reload errors on a local file' do
    error = assert_raises(ArgumentError) do
      local_file = Rails.root.join('test', 'fixtures', 'files', 'suggested_resources.csv').to_s
      Rake::Task['suggested_resources:reload'].invoke(local_file)
    end
    assert_equal 'Local files are not supported yet', error.message
  end

  test 'reload fails with a non-CSV file' do
    assert_raises(CSV::MalformedCSVError) do
      VCR.use_cassette('suggested_resource:reload from remote non-csv') do
        remote_file = 'http://static.lndo.site/suggested_resources.xlsx'
        Rake::Task['suggested_resources:reload'].invoke(remote_file)
      end
    end
  end

  test 'reload fails unless all three columns are present: title, url, phrase' do
    error = assert_raises(ArgumentError) do
      VCR.use_cassette('suggested_resource:reload with missing field') do
        remote_file = 'http://static.lndo.site/suggested_resources_missing_field.csv'
        Rake::Task['suggested_resources:reload'].invoke(remote_file)
      end
    end
    assert_equal 'Some CSV columns missing: ["Phrase"]', error.message
  end

  # assert_nothing_raised is viewed as an anti-pattern, but I'm leery of a test
  # with no assertions. As a result, we use a single assertion to confirm
  # something happened.
  test 'reload succeeds if extra columns are present' do
    records_before = Detector::SuggestedResource.count # We have three fixtures at the moment
    VCR.use_cassette('suggested_resource:reload with extra field') do
      remote_file = 'http://static.lndo.site/suggested_resources_extra.csv'
      Rake::Task['suggested_resources:reload'].invoke(remote_file)
    end
    refute_equal records_before, Detector::SuggestedResource.count
  end
end
