# == Schema Information
#
# Table name: categorizations
#
#  id                :integer          not null, primary key
#  detection_id      :integer
#  transaction_score :float
#  information_score :float
#  navigation_score  :float
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Categorization < ApplicationRecord
  belongs_to :detection

  def initialize(detection, *args)
    super(*args)
    self.detection = detection
    calculate_all
  end

  def evaluate
    scores = {
      :transactional => self.transaction_score,
      :informational => self.information_score,
      :navigational => self.navigation_score
    }

    max_score = scores.values.max
    max_keys = scores.select { |_, v| v == max_score }.keys

    if max_keys.size == 1
      max_keys.first
    else
      :unknown
    end
  end

  def calculate_all
    calculate_informational
    calculate_navigational
    calculate_transactional
  end

  def calculate_informational
    self.information_score = 0.0
  end

  def calculate_navigational
    self.navigation_score = 0.0
  end

  def calculate_transactional
    self.transaction_score = 0.0
    self.transaction_score = 1.0 if %i[doi isbn issn pmid journal].any? do |signal|
      self.detection[signal]
    end
  end
end
