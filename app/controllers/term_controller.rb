# frozen_string_literal: true

class TermController < ApplicationController
  include Pagy::Method

  # This provides the list of terms that are awaiting confirmation. By default this shows only terms which have been
  # categorized automatically. Adding `type=all` to the querystring will show _all_ terms which the user has not yet
  # confirmed.
  def unconfirmed
    terms = if params[:show] == 'all'
              authorize! :confirm_uncategorized, Term
              Term.user_unconfirmed
            else
              Term.categorized.user_unconfirmed
            end
    @pagy, @records = pagy(terms)
  end
end
