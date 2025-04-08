# frozen_string_literal: true

class DemoController < ApplicationController
  skip_before_action :require_user, only: %i[index view]

  def index; end

  def view
    @searchterm = params[:query]

    @term = Term.find_by(phrase: @searchterm)

    detections
  end

  private

  def detections
    @detections = {}

    @detections[:citation] = Detector::Citation.new(@searchterm).detections
    @detections[:journals] = Detector::Journal.new(@searchterm).detections
    @detections[:lcsh] = Detector::Lcsh.new(@searchterm).detections
    @detections[:standard_identifiers] = Detector::StandardIdentifiers.new(@searchterm).detections
    @detections[:suggested_resources] = Detector::SuggestedResource.full_term_match(@searchterm)
    @detections[:suggested_resources_patterns] = Detector::SuggestedResourcePattern.new(@searchterm)
  end
end
