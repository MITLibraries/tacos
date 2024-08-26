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
  # @param path [String] local file path to a CSV file to load
  # @param source [String] source name to load the data under
  desc 'Load search_events from csv'
  task :csv_loader, %i[path source] => :environment do |_task, args|
    raise ArgumentError.new, 'Path is required' if args.path.blank?
    raise ArgumentError.new, 'Source is required' if args.source.blank?

    Rails.logger.info("Loading data from #{args.path}")

    CSV.foreach(args.path) do |row|
      term = Term.create_or_find_by!(phrase: row.first)
      term.search_events.create!(source: args.source, created_at: row.last)
    end
  end

  desc 'Load search_events from url'
  task :url_loader, %i[addr source] => :environment do |_task, args|
    raise ArgumentError.new, 'URL is required' if args.addr.blank?
    raise ArgumentError.new, 'Source is required' if args.source.blank?

    Rails.logger.info("Term count before import: #{Term.count}")
    Rails.logger.info("SearchEvent count before import: #{SearchEvent.count}")

    url = URI.parse(args.addr)
    Rails.logger.info("Loading data from #{url}")

    file = url.open.read
    data = CSV.parse(file)
    data.each do |row|
      term = Term.create_or_find_by!(phrase: row.first)
      term.search_events.create!(source: args.source, created_at: row.last)
    end

    Rails.logger.info("Term count after import: #{Term.count}")
    Rails.logger.info("SearchEvent count after import: #{SearchEvent.count}")
  end
end
