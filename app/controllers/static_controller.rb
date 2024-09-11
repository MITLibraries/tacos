# frozen_string_literal: true

class StaticController < ApplicationController
  skip_before_action :require_user, only: :index

  def index
  end

  def playground
    authorize! :view, :playground

    render layout: false
  end
end
