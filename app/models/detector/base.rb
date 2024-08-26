# frozen_string_literal: true

# == Schema Information
#
# Table name: detector_bases
#
#  id         :integer          not null, primary key
#  name       :string
#  confidence :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
module Detector
  class Base < ApplicationRecord
  end
end
