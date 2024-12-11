# frozen_string_literal: true

class TermController < ApplicationController
  include Pagy::Backend

  # This provides the list of terms that are awaiting confirmation.
  def unconfirmed
    @pagy, @records = pagy(Term.user_unconfirmed)
  end
end
