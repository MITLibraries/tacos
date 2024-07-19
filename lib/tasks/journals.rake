# frozen_string_literal: true

# Loaders can bulk load data
namespace :journals do
  # openalex_harvester uses the OpenAleX Sources API endpoint to harvest to a local json file
  #
  # @note currently, we are limiting to just core Sources but not limiting to journals. We may want to consider
  # filtering to journals and not core to compare which is better at some point. This would be done by changing the
  # `base_url`. As of July 2024, there are 27722 `journal` and 2084 `book series` records in core which felt like a
  # good size for initial experimentation.
  #
  # @note see https://docs.openalex.org/api-entities/sources for full API documentation
  #
  # @example
  # @param path [String] email address OpenAlex can contact with any issues or concerns with our harvester.
  #   In development, use your own. If used in production, use a team Moira list.
  desc 'Harvest from Open Alex'
  task :openalex_harvester, %i[email] => :environment do |_task, args|
    raise ArgumentError.new, 'Email is required' unless args.email.present?

    base_url = 'https://api.openalex.org/sources?filter=is_core:true'
    next_cursor = '*'
    email = args.email
    sleep_timer = 1 # value in seconds
    per_page = 200 # max 200 per openalex api docs
    filename = "tmp/openalex_core_#{DateTime.now.strftime('%Y_%m_%d')}.json"

    f = File.open(filename, 'w')

    # setup initial json structure in the file. This feels a bit clunky but works.
    f.write('{')
    f.write('"core":[')

    records_processed = 0 # purely for informational output

    until next_cursor.nil?
      next_url = "#{base_url}&cursor=#{next_cursor}&per_page=#{per_page}&mailto=#{email}"

      Rails.logger.info("Next url request #{next_url}")
      resp = HTTP.headers(accept: 'application/json').get(next_url)

      json = resp.parse

      next_cursor = json['meta']['next_cursor']
      total_records = json['meta']['count']

      json['results'].each do |item|
        records_processed += 1
        record = {
          title: item['display_name'],
          issns: item['issn'],
          publisher: item['host_organization_name'],
          alternate_titles: item['alternate_titles'],
          abbreviated_title: item['abbreviated_title'],
          type: item['type']
        }
        f.write(JSON.pretty_generate(record))
        f.write(',') unless records_processed == total_records # skips final comma
      end

      pp "Processed #{records_processed} of #{total_records}"

      sleep(sleep_timer)
    end

    # close the json structure in the file
    f.write(']')
    f.write('}')
  end

  # openalex_loader can bulk load Journal information
  #
  # A file to load can be generated by running the `openalex_harvester` task
  #
  # @example
  # bin/rails journals:openalex_loader['local_path_to_file.json']
  #
  # @example
  # bin/rails journals:openalex_loader['https://SERVER/remote_path_to_file.json']
  #
  # @param path [String] local file path or URI to a JSON file to load
  desc 'Load from OpenAlex harvest'
  task :openalex_loader, %i[file] => :environment do |_task, args|
    raise ArgumentError.new, 'File is required' unless args.file.present?

    # does the file look like a path or a URI
    if URI(args.file).scheme
      Rails.logger.info("Loading data from remote file #{args.file}")
      data = URI.open(args.file, 'rb', &:read)
    else
      Rails.logger.info("Loading data from local file #{args.file}")
      data = File.read(args.file)
    end

    # Delete all journals. We do this to simplify the loader process to avoid consideration of updates/deletes.
    Detector::Journal.delete_all

    # not ideal, we should consider streaming the file rather than loading it fully into memory
    json = JSON.parse(data)

    json['core'].each do |journal|
      Detector::Journal.create(name: journal['title'],
                               additional_info: { issns: journal['issns'],
                                                  publisher: journal['publisher'],
                                                  alternate_titles: journal['alternate_titles'],
                                                  type: journal['type'],
                                                  abbreviated_title: journal['abbreviated_title'] })
    end
  end
end
