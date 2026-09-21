# frozen_string_literal: true

class SuggestedResourceController < ApplicationController
  before_action :authorize

  def authorize
    authorize! :manage, :suggestions
  end

  def index
    @resources = SuggestedResource.includes(:terms)
  end

  def new
    @resource = SuggestedResource.new
  end

  def edit
    @resource = SuggestedResource.find(params.expect(:id))
  end

  def create
    resource = SuggestedResource.new(suggested_resource_params)

    if record.save
      flash[:success] = "Suggested Resource \"#{record.title}\" created"
      flash[:success] = "Suggested Resource \"#{resource.title}\" created"

      redirect_to suggested_resource_path
    else
      flash[:error] = "Suggested Resource \"#{resource.title}\" could not be created"

      redirect_back_or_to suggested_resource_new_path
    end
  end

  def update
    record = SuggestedResource.find(params.expect(:id))

    if record.update(suggested_resource_params)
      flash[:success] = "Suggested Resource \"#{resource.title}\" updated"

      redirect_to suggested_resource_path
    else
      flash[:error] = "Suggested Resource \"#{resource.title}\" could not be updated"

      redirect_back_or_to suggested_resource_path
    end
  end

  private

  def suggested_resource_params
    params.expect(suggested_resource: %i[title url])
  end
end
