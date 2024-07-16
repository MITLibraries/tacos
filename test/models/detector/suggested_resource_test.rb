# == Schema Information
#
# Table name: detector_suggested_resources
#
#  id          :integer          not null, primary key
#  title       :string
#  url         :string
#  phrase      :string
#  fingerprint :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
require "test_helper"

class Detector::SuggestedResourceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
