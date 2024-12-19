# frozen_string_literal: true

# == Schema Information
#
# Table name: journals
#
#  id              :integer          not null, primary key
#  name            :string
#  additional_info :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# Journal is the list of academic journals which are known to TACOS. This list of records is referred to by the
# Detector::Journal model in order to determine whether a given term matches a known journal. The names of these
# journals are stored in lowercase, which matches how the Detector::Journal processes incoming terms, in order to
# prevent capitalization differences resulting in a false negative.
class Journal < ApplicationRecord
  before_save :downcase_fields!

  private

  # Downcasing all names before saving allows for more efficient matching by ensuring our index is lowercase.
  # If we find we need the non-lowercase Journal name in the future, we could store that as `additional_info` json
  def downcase_fields!
    name.downcase!
  end
end
