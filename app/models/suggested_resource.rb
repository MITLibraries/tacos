# frozen_string_literal: true

# == Schema Information
#
# Table name: suggested_resources
#
#  id          :integer          not null, primary key
#  title       :string
#  url         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#  confidence  :float            default(0.9)
#
class SuggestedResource < ApplicationRecord
  has_many :terms, dependent: :nullify
  has_many :fingerprints, through: :terms, dependent: :nullify

  belongs_to :category, optional: true

  # This replaces all current SuggestedResource records with a new set from an imported CSV.
  #
  # @note This method is called by the suggested_resource:reload rake task.
  #
  # @param input [CSV::Table] An imported CSV file containing all Suggested Resource records. The CSV file must have
  #                           at least three headers, named "Title", "URL", and "Phrase". Please note: these values
  #                           are case sensitive.
  def self.bulk_replace(input)
    raise ArgumentError.new, 'Tabular CSV is required' unless input.instance_of?(CSV::Table)

    # Need to check what columns exist in input
    required_headers = %w[title url phrase]
    missing_headers = required_headers - input.headers
    raise ArgumentError.new, "Some CSV columns missing: #{missing_headers}" unless missing_headers.empty?

    SuggestedResource.destroy_all

    input.each do |line|
      term = Term.find_or_create_by(phrase: line['phrase'])

      # check for existing SuggestedResource with the same title/url
      dup_check = SuggestedResource.where(title: line['title'], url: line['url'])

      # link to existing SuggestedResource if one exists
      term.suggested_resource = if dup_check.count.positive?
                                  dup_check.first
                                # create a new SuggestedResource if it doesn't exist
                                else
                                  SuggestedResource.new({ title: line['title'], url: line['url'] })
                                end
      term.save
    end
  end
end
