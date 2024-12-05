# frozen_string_literal: true

# == Schema Information
#
# Table name: term_fingerprints
#
#  id          :integer          not null, primary key
#  fingerprint :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class TermFingerprint < ApplicationRecord
  has_many :terms, dependent: :nullify

  validates :fingerprint, uniqueness: true
end
