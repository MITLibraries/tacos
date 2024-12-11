# frozen_string_literal: true

class ConfirmationController < ApplicationController
  rescue_from ActiveRecord::RecordNotUnique, with: :error_not_unique

  # new populates instance variables used by the new confirmation form.
  def new
    @term = Term.find(params[:term_id])
    @categories = Category.all
    @confirmation = Confirmation.new
  end

  # create receives the submission from the new confirmation form, creating the needed record with the help of various
  # private methods.
  def create
    new_record = Confirmation.new(confirmation_params)

    if new_record.save
      # Now that the confirmation has saved, set the flag on the related Term record.
      flag_term(params[:term_id]) if confirmation_flag?(params[:confirmation][:category_id])

      # By this point, saving has succeeded
      feedback_for(confirmation_flag?(params[:confirmation][:category_id]))
      redirect_to terms_unconfirmed_path
    else
      error_cannot_save
    end
  end

  private

  def confirmation_params
    params.require(:confirmation).permit(:term_id, :category_id, :user_id)
  end

  # feedback_for defines an appropriate flash message, based on whether the user has placed the term in the "flagged"
  # category or not.
  def feedback_for(flagged)
    if flagged == true
      flash[:success] = 'Term flagged for review'
    else
      flash[:success] = "Term confirmed as #{Category.find_by(id: params[:confirmation][:category_id]).name}"
    end
  end

  # error_cannot_save catches cases where the received Confirmation record cannot be saved, for whatever reason.
  def error_cannot_save
    flash[:error] = 'Unable to finish confirming this term. Please try again, or try a different term.'
    Sentry.capture_message('Unable to confirm term in a category')
    redirect_to terms_unconfirmed_path
  end

  # error_not_unique catches the RecordNotUnique error in case a duplicate confirmation is ever submitted, and shows an
  # appropriate error message to the user.
  def error_not_unique(exception)
    flash[:error] = 'Duplicate confirmations are not supported'
    Sentry.capture_message(exception.message)
    redirect_to terms_unconfirmed_path
  end

  # flag_term sets the "flagged" boolean field on a Term record when a Confirmation comes in for that category.
  def flag_term(term_id)
    t = Term.find_by(id: term_id)
    t.flag = true
    t.save
  end

  # confirmation_flag? compares the submitted category (coerced to an integer) to the ID value for the "flagged"
  # category.
  #
  # @param submission e.g. params[:confirmation][:category]
  # @return boolean
  def confirmation_flag?(submission)
    submission.to_i == Category.find_by(name: 'Flagged').id
  end
end
