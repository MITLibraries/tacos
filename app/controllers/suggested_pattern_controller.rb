# frozen_string_literal: true

class SuggestedPatternController < ApplicationController
  before_action :authorize

  def authorize
    authorize! :manage, :suggestions
  end

  def index
    @resources = SuggestedPattern.all
  end

  def new
    @resource = SuggestedPattern.new
  end

  def edit
    @resource = SuggestedPattern.find(params.expect(:id))
  end

  def create
    resource = SuggestedPattern.new(suggested_pattern_params)

    if resource.save
      flash[:success] = "Suggested Pattern \"#{resource.title}\" created"

      redirect_to suggested_pattern_path
    else
      flash[:error] = "Suggested Pattern \"#{resource.title}\" could not be created"

      redirect_back_or_to suggested_pattern_new_path
    end
  end

  def update
    resource = SuggestedPattern.find(params.expect(:id))

    if resource.update(suggested_pattern_params)
      flash[:success] = "Suggested Pattern \"#{resource.title}\" updated"

      redirect_to suggested_pattern_path
    else
      flash[:error] = "Suggested Pattern \"#{resource.title_in_database}\" could not be updated"

      redirect_back_or_to suggested_pattern_path
    end
  end

  private

  def suggested_pattern_params
    params.expect(suggested_pattern: %i[title url pattern shortcode])
  end
end
