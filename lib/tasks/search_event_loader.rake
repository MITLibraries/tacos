# frozen_string_literal: true

require 'csv'

# Loaders can bulk load data
namespace :search_events do
  # csv loader can bulk load SearchEvents and Terms.
  #
  # @note For use in development environments only. Duplicate search events will be created if the same CSV is loaded
  #   multiple times.
  #
  # @note the csv should be formated as `term phrase`, `timestamp`. A dataclip is available that can export in this
  #   format.
  # @example
  # bin/rails search_events:csv_loader['local_path_to_file.csv', 'some-source-to-use-for-all-loaded-records']
  #
  # @example
  # bin/rails search_events:csv_loader['https://SERVER/remote_path_to_file.json', 'some-source-to-use-for-all-loaded-records']
  #
  # @param path [String] local file path to a CSV file to load
  # @param source [String] source name to load the data under
  desc 'Load search_events from csv'
  task :csv_loader, %i[path source] => :environment do |_task, args|
    raise ArgumentError.new, 'Path is required' if args.path.blank?
    raise ArgumentError.new, 'Source is required' if args.source.blank?

    # does the file look like a path or a URI
    if URI(args.path).scheme
      Rails.logger.info("Loading data from remote file #{args.path}")
      data = URI.parse(args.path).open('rb', &:read)
    else
      Rails.logger.info("Loading data from local file #{args.path}")
      data = File.read(args.path)
    end

    # not ideal, we should consider streaming the file rather than loading it fully into memory
    # if you run into issues with this, consider loading subsets (such as a single month) at a time
    CSV.parse(data, headers: true) do |row|
      term = Term.create_or_find_by!(phrase: row['phrase'])
      if row['label']
        term.label = row['label']
      else
        term.label = nil
      end
      term.save
      source = row['source'] || args.source
      term.search_events.create!(source: source, created_at: row['created_at'])
    end
  end
end
