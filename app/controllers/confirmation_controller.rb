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
                                      user: current_user
                                    })
    set_category(confirmation, params[:confirmation][:category])
    feedback_for(confirmation.save)
    redirect_to terms_unconfirmed_path
  end

  private

  # feedback_for takes the result of the confirmation.save directive above and sets an appropriate flash message.
  #
  # The final else clause is likely to be difficult to provoke, so we are sending a Sentry message in that block in
  # order to prompt further investigation.
  def feedback_for(result)
    if result == true && params[:confirmation][:category] == 'flag'
      flash[:success] = 'Term flagged for review'
    elsif result == true
      flash[:success] = "Term confirmed as #{Category.find_by(id: params[:confirmation][:category]).name}"
    else
      flash[:error] = 'Unable to finish confirming this term. Please try again, or try a different term.'
      Sentry.capture_message('Unable to confirm term in a category')
    end
  end

  # error_not_unique catches the RecordNotUnique error in case a duplicate confirmation is ever submitted, and shows an
  # appropriate error message to the user.
  def error_not_unique(exception)
    flash[:error] = 'Duplicate confirmations are not supported'
    Sentry.capture_message(exception.message)
    redirect_to terms_unconfirmed_path
  end

  # The confirmation form lists options for each Category record, and then one extra option to flag the term for
  # removal. "Flag" is not a category, but a separate boolean field on the Confirmation model.
  #
  # set_category takes the submitted "category" field from the form and either assigns the appropriate numeric value for
  # the chosen cateogory, or sets the boolean "flag" field to true.
  def set_category(confirmation, category)
    if category == 'flag'
      confirmation.flag = true
    else
      confirmation.category_id = category
    end
  end
end
