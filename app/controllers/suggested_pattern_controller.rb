# frozen_string_literal: true

class SuggestedPatternController < ApplicationController
  before_action :authorize

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

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

  # We are using delete instead of destroy because this application doesn't implement any of the hooks or guardrails
  # from which a destroy operation would benefit.
  def delete
    resource = SuggestedPattern.find(params.expect(:id))
    resource.delete

    flash[:success] = "Suggested Pattern \"#{resource.title}\" deleted"

    redirect_to suggested_pattern_path
  end

  private

  def not_found
    flash[:error] = "Requested Suggested Pattern (id: #{params[:id]}) not found"
    redirect_back_or_to suggested_pattern_path
  end

  def suggested_pattern_params
    params.expect(suggested_pattern: %i[title url pattern shortcode])
  end
end
