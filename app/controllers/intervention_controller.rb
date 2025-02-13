# frozen_string_literal: true

class InterventionController < ApplicationController
  skip_before_action :require_user

  def doi
    @doi = params[:doi]

    raise ActionController::RoutingError.new('Not Found') unless params[:doi].present?

    @json = if ENV.fetch('LIBKEY_DOI', nil)
              LookupLibkey.info(doi: @doi)
            else
              LookupDoi.new.info(@doi)
            end

    render 'doi', layout: false
  end
end
