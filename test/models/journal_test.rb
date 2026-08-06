# frozen_string_literal: true

# == Schema Information
#
# Table name: journals
#
#  id              :integer          not null, primary key
#  additional_info :json
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_journals_on_name  (name)
#
require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  test 'mixed titles are downcased when saved' do
    mixed_case = 'ThIs Is A tItLe'
    actual = Journal.create(name: mixed_case)
    actual.reload

    assert_not_equal(mixed_case, actual.name)
    assert_equal(mixed_case.downcase, actual.name)
  end
end
