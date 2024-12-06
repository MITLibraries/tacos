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
    confirmation = Confirmation.new({
                                      term_id: params[:term_id],
                                      category_id: params[:confirmation][:category_id],
                                      user: current_user
                                    })

    # Guard clause in case saving fails
    error_cannot_save unless confirmation.save

    # Now that the confirmation has saved, set the flag on the related Term record.
    flag_term(params[:term_id]) if confirmation_flag?(params[:confirmation][:category_id])

    # By this point, saving has succeeded
    feedback_for(confirmation_flag?(params[:confirmation][:category_id]))
    redirect_to terms_unconfirmed_path
  end

  private

  # feedback_for takes the result of the confirmation.save directive above and sets an appropriate flash message.
  #
  # The final else clause is likely to be difficult to provoke, so we are sending a Sentry message in that block in
  # order to prompt further investigation.
  def feedback_for(flagged)
    if flagged == true
      flash[:success] = 'Term flagged for review'
    else
      flash[:success] = "Term confirmed as #{Category.find_by(id: params[:confirmation][:category_id]).name}"
    end
  end

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

  # confirmation_flag? compares the submitted category (coerced to an integer) to the ID value for the "flagged" category. We
  # do this at least twice in this controller.
  #
  # @param submission e.g. params[:confirmation][:category]
  # @return boolean
  def confirmation_flag?(submission)
    submission.to_i == Category.find_by(name: 'Flagged').id
  end
end
