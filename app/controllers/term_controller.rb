# frozen_string_literal: true

class TermController < ApplicationController
  include Pagy::Backend

  def confirm_index
    @pagy, @records = pagy(Term.user_unconfirmed)
  end

  def confirm_term
    @term = Term.find(params[:id])
    @categories = Category.all
  end
end
