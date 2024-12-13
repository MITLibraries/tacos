# frozen_string_literal: true

require 'test_helper'
require 'rake'

class FingerprintsRakeTest < ActiveSupport::TestCase
  def setup
    Tacos::Application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['fingerprints:generate'].reenable
  end

  test 'all terms are fingrprinted after generation task' do
    f = Fingerprint.last
    f.destroy

    assert_not_nil Term.find_by(fingerprint: nil)

    Rake::Task['fingerprints:generate'].invoke

    assert_nil Term.find_by(fingerprint: nil)
  end
end
