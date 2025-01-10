# frozen_string_literal: true

class InterventionController < ApplicationController
  skip_before_action :require_user

  def doi
    @doi = params[:doi]

    @json = LookupDoi.new.info(@doi)

    render 'doi', layout: false
  end
end
