# frozen_string_literal: true

# This is a quick bulk export tool to check the citation calculations
namespace :citations do
  desc 'Export citation calculations'
  task :export => :environment do
    Rails.logger.info("Preparing to export citation calculations for #{Term.count} phrases")
    CSV.open('citation_results.csv', 'w') do |csv|
      csv << [
        'score',
        'apa',
        'brackets',
        'colons',
        'commas',
        'lastnames',
        'no',
        'pages',
        'periods',
        'pp',
        'quotes',
        'semicolons',
        'vol',
        'words',
        'year',
        'non_zero_features',
        'term_id',
        'label',
        'phrase'
      ]
      Term.all.each_with_index do |t, index|
        t.save
        t.reload
        result = Detector::Citation.new(t.phrase)
        csv << [
          result.score,
          result.features[:apa_volume_issue],
          result.features[:brackets],
          result.features[:colons],
          result.features[:commas],
          result.features[:lastnames],
          result.features[:no],
          result.features[:pages],
          result.features[:periods],
          result.features[:pp],
          result.features[:quotes],
          result.features[:semicolons],
          result.features[:vol],
          result.features[:words],
          result.features[:year_parens],
          result.features.except(:characters).values.count { |v| v != 0 },
          t.id,
          t.label,
          t.phrase
        ]
        Rails.logger.info("Completed #{index}") if (index / 100) * 100 == index
      end
    end
  end

  # The import task is used to ingest labels for use by the citation scoring
  # process. This process will overwrite any existing labels for records in the
  # provided CSV file.
  #
  # This is meant to be used to load local data only.
  desc 'Import labels for citations'
  task :import, %i[path] => :environment do |_task, args|
    raise ArgumentError.new, 'Path is required' if args.path.blank?

    Rails.logger.info("Loading data from local file #{args.path}")
    data = File.read(args.path)

    CSV.parse(data, headers: true) do |row|
      Rails.logger.info("Term: #{row['Phrase']}")

      term = Term.find_or_create_by(phrase: row['Phrase'])
      term.label = row['Label'].to_s.downcase == "true"

      Rails.logger.info("  Imported label: #{row['Label']} as #{term.label}")

      term.save
    end
  end
end
