# This is a quick bulk export tool to check the citation calculations
namespace :citations do
  desc 'Export citation calculations'
  task :export => :environment do
    Rails.logger.info("Preparing to export citation calculations for #{Term.count} phrases")
    CSV.open('citation_results.csv','w') do |csv|
      csv << [
        "Score",
        "Characters",
        "Colons",
        "Commas",
        "Periods",
        "Semicolons",
        "Words",
        "APA",
        "No",
        "Pages",
        "PP",
        "Vol",
        "Year",
        "Brackets",
        "Lastnames",
        "Quotes",
        "FingerprintID",
        "ClusterSize",
        "TermID",
        "Phrase"
      ]
      Term.all.each_with_index do |t, index|
        t.save
        t.reload
        result = Detector::Citation.new(t.phrase)
        csv << [
          result.score,
          result.summary[:characters],
          result.summary[:colons],
          result.summary[:commas],
          result.summary[:periods],
          result.summary[:semicolons],
          result.summary[:words],
          result.subpatterns.fetch(:apa_volume_issue, '').length,
          result.subpatterns.fetch(:no, '').length,
          result.subpatterns.fetch(:pages, '').length,
          result.subpatterns.fetch(:pp, '').length,
          result.subpatterns.fetch(:vol, '').length,
          result.subpatterns.fetch(:year_parens, '').length,
          result.subpatterns.fetch(:brackets, '').length,
          result.subpatterns.fetch(:lastnames, '').length,
          result.subpatterns.fetch(:quotes, '').length,
          t.fingerprint_id,
          t.fingerprint.terms.count,
          t.id,
          t.phrase
        ]
        Rails.logger.info("Completed #{index}") if ((index/100)*100 == index)
      end
    end
  end
end
