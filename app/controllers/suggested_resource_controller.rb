# frozen_string_literal: true

class SuggestedResourceController < ApplicationController
  before_action :authorize

  def authorize
    authorize! :manage, :suggestions
  end

  def index
    @resources = SuggestedResource.includes(:terms)
  end
end
