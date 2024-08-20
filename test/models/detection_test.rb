# == Schema Information
#
# Table name: detections
#
#  id                :integer          not null, primary key
#  term_id           :integer
#  detection_version :integer
#  doi               :boolean
#  isbn              :boolean
#  issn              :boolean
#  pmid              :boolean
#  journal           :boolean
#  suggestedresource :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'test_helper'

class DetectionTest < ActiveSupport::TestCase
  test 'detection_version is set from env automatically' do
    result = Detection.new(terms(:cool))

    assert_equal ENV.fetch('DETECTION_VERSION').to_i, result.detection_version
  end

  test 'Detection records have a record of what term was processed' do
    result = Detection.new(terms(:cool))

    assert_equal terms(:cool), result.term
  end
end
