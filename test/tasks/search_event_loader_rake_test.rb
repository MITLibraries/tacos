# frozen_string_literal: true

require 'test_helper'
require 'rake'

class SearchEventLoaderRakeTest < ActiveSupport::TestCase
  def setup
    Tacos::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['search_events:url_loader'].reenable
  end

  test 'url_reload can accept a url and source parameter' do
    records_before = SearchEvent.count
    VCR.use_cassette('search_events:url_loader from remote csv') do
      remote_file = 'http://static.lndo.site/search_events.csv'
      Rake::Task['search_events:url_loader'].invoke(remote_file, 'test')
    end

    assert_not_equal records_before, SearchEvent.count
  end

  test 'url_reload errors without any parameters' do
    error = assert_raises(ArgumentError) do
      Rake::Task['search_events:url_loader'].invoke()
    end
    assert_equal 'URL is required', error.message
  end

  test 'url_reload errors without a source parameter' do
    error = assert_raises(ArgumentError) do
      remote_file = 'http://static.lndo.site/search_events.csv'
      Rake::Task['search_events:url_loader'].invoke(remote_file)
    end
    assert_equal 'Source is required', error.message
  end

end
