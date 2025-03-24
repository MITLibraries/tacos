# frozen_string_literal: true

require 'test_helper'
require 'rake'

class SearchEventLoaderRakeTest < ActiveSupport::TestCase
  def setup
    Tacos::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['search_events:csv_loader'].reenable
  end

  test 'csv_loader can accept a url and source parameter' do
    records_before = SearchEvent.count
    VCR.use_cassette('search_events:url_loader from remote csv') do
      remote_file = 'http://static.lndo.site/search_events.csv'
      Rake::Task['search_events:csv_loader'].invoke(remote_file, 'test')
    end

    assert_not_equal records_before, SearchEvent.count
  end

  test 'csv_loader errors without any parameters' do
    error = assert_raises(ArgumentError) do
      Rake::Task['search_events:csv_loader'].invoke
    end
    assert_equal 'Path is required', error.message
  end

  test 'csv_loader errors without a source parameter' do
    error = assert_raises(ArgumentError) do
      remote_file = 'http://static.lndo.site/search_events.csv'
      Rake::Task['search_events:csv_loader'].invoke(remote_file)
    end
    assert_equal 'Source is required', error.message
  end

  test 'csv_loader can accept labelled records' do
    records_before = SearchEvent.count
    VCR.use_cassette('search_events:url_loader from remote labelled csv') do
      remote_file = 'http://static.lndo.site/search_events_labelled.csv'
      Rake::Task['search_events:csv_loader'].invoke(remote_file, 'test')
    end

    assert_not_equal records_before, SearchEvent.count
  end
end
