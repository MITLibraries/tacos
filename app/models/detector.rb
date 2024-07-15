# frozen_string_literal: true

# Detectors are classes that implement various algorithms that allow us to identify patterns
# within search terms.
module Detector
  def self.table_name_prefix
    'detector_'
  end
end
