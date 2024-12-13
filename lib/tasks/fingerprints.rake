# frozen_string_literal: true

namespace :fingerprints do
  # generate will create (or re-create) fingerprints for all existing Terms.
  desc 'Generate fingerprints for all terms'
  task generate: :environment do |_task|
    Rails.logger.info("Generating fingerprints for all #{Term.count} terms")

    Term.find_each.with_index do |t, index|
      t.save
      Rails.logger.info("Processed #{index}") if index == (index / 1000) * 1000
    end
  end
end
