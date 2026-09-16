# frozen_string_literal: true

class SuggestedResourceController < ApplicationController
  before_action :authorize

  def authorize
    authorize! :manage, :suggestions
  end

  def index
    @records = SuggestedResource.all
  end
end
