# frozen_string_literal: true

class DemoController < ApplicationController
  skip_before_action :require_user, only: %i[index view]

  def index
  end

  def view
    @searchterm = params[:query]

    @term = Term.find_by(phrase: @searchterm)
    # Have we seen this before? (lookup Term)
    # If yes, use stored data
    # If no, use Detectors directly
    detections

    Rails.logger.debug('Good greetings!')
  end

  private

  def detections
    @detections = {}

    @detections[:citation] = Detector::Citation.new(@searchterm).detections
    @detections[:standard_identifiers] = Detector::StandardIdentifiers.new(@searchterm).detections
    @detections[:journals] = Detector::Journal.new(@searchterm).detections
    @detections[:lcsh] = Detector::Lcsh.new(@searchterm).detections
    @detections[:suggested_resources] = Detector::SuggestedResource.full_term_match(@searchterm)
  end
end
