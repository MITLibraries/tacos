# frozen_string_literal: true

class ValidationController < ApplicationController
  # The index method is intended to return an array of all Term records which have triggered any action by TACOS. In
  # practice this means at least a Detection, and hopefully also a Categorization.
  #
  # At the moment, this method is subject to a few shortcomings:
  # - Outdated Detections are being returned, whose DETECTOR_VERSION value does not match the current value.
  # - We should probably have a way of validating Terms which triggered no action, but should have. However, without
  #   some filtering, this query will return tens of thousands of records, which is unwieldy.
  # - Users will probably not need to see terms listed which they've already validated, so filtering out terms which the
  #   current user has already processed should probably be added.
  #
  # @return @terms is an array of term records for inclusion in the list of records
  def index
    @terms = Term.joins(:detections).uniq
  end

  # The term method is intended to return three instance variables, which together are used to build the validation
  # interface.
  #
  # @return @term a hash of all information a term, including it's current associated Detections and Categorizations.
  # @return @detectors An array of all Detectors defined within the application.
  # @return @categories An array of all Categories defined within the application.
  def term
    @term = Term.find(params[:id])
    @detectors = Detector.all
    @categories = Category.all
  end
end
