# == Schema Information
#
# Table name: term_detectinators
#
#  id              :integer          not null, primary key
#  term_id         :integer
#  detectinator_id :integer
#  result          :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class TermDetectinator < ApplicationRecord
  belongs_to :term
  belongs_to :detectinator

  def initialize(term, *args)
    super(*args)
    self.term = term
  end
end
