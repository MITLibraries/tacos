# frozen_string_literal: true

require 'test_helper'
require 'rake'

class SuggestedResourceRakeTest < ActiveSupport::TestCase
  def setup
    Tacos::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['suggested_resources:reload'].reenable
  end

  test 'reload can accept a url' do
    records_before = SuggestedResource.count # We have three fixtures at the moment
    first_record_before = SuggestedResource.first
    VCR.use_cassette('suggested_resource:reload from remote csv') do
      remote_file = 'http://static.lndo.site/suggested_resources.csv'
      Rake::Task['suggested_resources:reload'].invoke(remote_file)
    end

    assert_not_equal records_before, SuggestedResource.count
    assert_not_equal first_record_before, SuggestedResource.first
  end

  test 'reload task errors without a file argument' do
    error = assert_raises(ArgumentError) do
      Rake::Task['suggested_resources:reload'].invoke
    end
    assert_equal 'URL is required', error.message
  end

  test 'reload errors on a local file' do
    error = assert_raises(ArgumentError) do
      local_file = Rails.root.join('test/fixtures/files/suggested_resources.csv').to_s
      Rake::Task['suggested_resources:reload'].invoke(local_file)
    end
    assert_equal 'Local files are not supported yet', error.message
  end

  test 'reload fails with a non-CSV file' do
    assert_raises(CSV::MalformedCSVError) do
      VCR.use_cassette('suggested_resource:reload from remote non-csv') do
        remote_file = 'http://static.lndo.site/suggested_resources.txt'
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
    assert_equal 'Some CSV columns missing: ["phrase"]', error.message
  end

  # assert_nothing_raised is viewed as an anti-pattern, but I'm leery of a test
  # with no assertions. As a result, we use a single assertion to confirm
  # something happened.
  test 'reload succeeds if extra columns are present' do
    records_before = SuggestedResource.count # We have three fixtures at the moment
    VCR.use_cassette('suggested_resource:reload with extra field') do
      remote_file = 'http://static.lndo.site/suggested_resources_extra.csv'
      Rake::Task['suggested_resources:reload'].invoke(remote_file)
    end

    assert_not_equal records_before, SuggestedResource.count
  end

  test 'reload handles duplicate titles in CSV' do
    terms_before = Term.count
    resources_before = SuggestedResource.count
    VCR.use_cassette('suggested_resource:reload dup title') do
      remote_file = 'http://static.lndo.site/suggested_resources_dup_title.csv'
      Rake::Task['suggested_resources:reload'].invoke(remote_file)
    end

    # Because both titles are the same, confirm that one, not two, new suggested resource was created. Two terms should
    # be created.
    assert resources_before + 1, SuggestedResource.count
    assert terms_before + 2, Term.count
  end

  test 'reload handles duplicate URLs in CSV' do
    terms_before = Term.count
    resources_before = SuggestedResource.count
    VCR.use_cassette('suggested_resource:reload dup url') do
      remote_file = 'http://static.lndo.site/suggested_resources_dup_urls.csv'
      Rake::Task['suggested_resources:reload'].invoke(remote_file)
    end

    # Because both URLs are the same, confirm that one suggested resource, not two, was created. Two terms should be
    # created.
    assert resources_before + 1, SuggestedResource.count
    assert terms_before + 2, Term.count
  end

  test 'reload handles duplicate phrases in CSV' do
    terms_before = Term.count
    resources_before = SuggestedResource.count
    VCR.use_cassette('suggested_resource:reload dup phrases') do
      remote_file = 'http://static.lndo.site/suggested_resources_dup_phrases.csv'
      Rake::Task['suggested_resources:reload'].invoke(remote_file)
    end

    # Because both phrases are the same, confirm that one term, not two, was created. Two suggested resources should be
    # created.
    assert terms_before + 1, Term.count
    assert resources_before + 2, SuggestedResource.count
  end

  test 'reload handles phrases that match existing terms' do
    terms_before = Term.count
    all_terms = Term.all
    resources_before = SuggestedResource.count
    VCR.use_cassette('suggested_resource:reload existing term') do
      remote_file = 'http://static.lndo.site/suggested_resources_existing_term.csv'
      Rake::Task['suggested_resources:reload'].invoke(remote_file)
    end

    # Confirm that one term, not two, is created. (One of the two phrases, web of science is an existing term.) Two
    # suggested resources should be created.
    assert_equal terms_before + 1, Term.count
    assert resources_before + 1, SuggestedResource.count
  end
end
