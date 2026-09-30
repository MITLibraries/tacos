# frozen_string_literal: true

class SuggestedResourceController < ApplicationController
  before_action :authorize

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

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

    ActiveRecord::Base.transaction do
      update_term_associations(resource, params) if params[:term]

      raise ActiveRecord::Rollback unless resource.save
    end

    if resource.errors.none?
      flash[:success] = "Suggested Resource \"#{resource.title}\" created"

      redirect_to suggested_resource_path
    else
      flash[:error] = "Suggested Resource \"#{resource.title}\" could not be created"

      redirect_back_or_to suggested_resource_new_path
    end
  end

  def update
    resource = SuggestedResource.find(params.expect(:id))

    ActiveRecord::Base.transaction do
      update_term_associations(resource, params) if params[:term]

      raise ActiveRecord::Rollback unless resource.update(suggested_resource_params)
    end

    if resource.errors.none?
      flash[:success] = "Suggested Resource \"#{resource.title}\" updated"

      redirect_to suggested_resource_path
    else
      flash[:error] = "Suggested Resource \"#{resource.title_in_database}\" could not be updated"

      redirect_back_or_to suggested_resource_path
    end
  end

  # We are using delete instead of destroy because this application doesn't implement any of the hooks or guardrails
  # from which a destroy operation would benefit.
  def delete
    resource = SuggestedResource.find(params.expect(:id))
    resource.delete

    flash[:success] = "Suggested Resource \"#{resource.title}\" deleted"

    redirect_to suggested_resource_path
  end

  private

  def update_term_associations(resource, params)
    return resource unless params[:term]

    # Remove flagged terms from resource
    params[:term][:delete]&.each do |t|
      resource.terms.delete(Term.find_by(id: t))
    end

    # Create new terms as needed
    params[:term][:append]&.each do |t|
      resource.terms.append(Term.find_or_create_by(phrase: t)) unless t.strip.empty?
    end

    resource
  end

  def not_found
    flash[:error] = "Requested Suggested Resource (id: #{params[:id]}) not found"
    redirect_back_or_to suggested_resource_path
  end

  def suggested_resource_params
    params.expect(suggested_resource: %i[title url])
  end
end
