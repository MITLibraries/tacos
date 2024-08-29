# == Schema Information
#
# Table name: validations
#
#  id                       :integer          not null, primary key
#  categorization_id        :integer
#  valid_category           :boolean
#  valid_transaction        :boolean
#  valid_information        :boolean
#  valid_navigation         :boolean
#  valid_doi                :boolean
#  valid_isbn               :boolean
#  valid_issn               :boolean
#  valid_pmid               :boolean
#  valid_journal            :boolean
#  valid_suggested_resource :boolean
#  flag_term                :boolean
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
class Validation < ApplicationRecord
  belongs_to :categorization

  def initialize(categorization, *args)
    super(*args)
    self.categorization = categorization
  end
end
