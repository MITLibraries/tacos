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
end
