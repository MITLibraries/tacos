# frozen_string_literal: true

require 'csv'

# These define tasks for managing our SuggestedResource records.
namespace :suggested_resources do
  # While we intend to use Dataclips for exporting these records when needed,
  # we do need a way to import records from a CSV file.
  desc 'Replace all Suggested Resources from CSV'
  task :reload, [:addr] => :environment do |_task, args|
    raise ArgumentError.new, 'URL is required' if args.addr.blank?

    raise ArgumentError.new, 'Local files are not supported yet' unless URI(args.addr).scheme

    Rails.logger.info('Reloading all Suggested Resource records from CSV')

    url = URI.parse(args.addr)

    raise ArgumentError.new, 'HTTP/HTTPS scheme is required' unless url.scheme.in?(%w[http https])

    file = url.open.read.gsub("\xEF\xBB\xBF", '').force_encoding('UTF-8').encode
    data = CSV.parse(file, headers: true)

    Rails.logger.info("Record count before we reload: #{Detector::SuggestedResource.count}")

    Detector::SuggestedResource.bulk_replace(data)

    Rails.logger.info("Record count after we reload: #{Detector::SuggestedResource.count}")
  end
end
