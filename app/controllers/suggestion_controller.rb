# frozen_string_literal: true

class SuggestionController < ApplicationController
  before_action :authorize

  def authorize
    authorize! :manage, :suggestions
  end

  def index
    @resources = SuggestedResource.count
    @patterns = SuggestedPattern.count
  end
end
