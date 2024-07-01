# frozen_string_literal: true

require 'csv'

# Loaders can bulk load data
namespace :search_events do
  # csv loader can bulk load SearchEvents and Terms
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
    raise ArgumentError.new, 'Path is required' unless args.path.present?
    raise ArgumentError.new, 'Source is required' unless args.source.present?

    Rails.logger.info("Loading data from #{args.path}")

    CSV.foreach(args.path) do |row|
      term = Term.create_or_find_by!(phrase: row.first)
      term.search_events.create!(source: args.source, created_at: row.last)
    end
  end
end
