# frozen_string_literal: true

class SuggestedPatternController < ApplicationController
  before_action :authorize

  def authorize
    authorize! :manage, :suggestions
  end

  def index
    @records = SuggestedPattern.all
  end
end
