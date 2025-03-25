# frozen_string_literal: true

class TermController < ApplicationController
  include Pagy::Backend

  def score
    @buckets = {}
    @buckets['true_positive'] = 0
    @buckets['false_positive'] = 0
    @buckets['false_negative'] = 0
    @buckets['true_negative'] = 0
    @scores = {}
    @scores['scored'] = 0
    @scores['f1'] = 0.0

    Term.labelled.each do |subject|
      Rails.logger.info('-----------------------------------')
      Rails.logger.info(subject.phrase)
      result = Detector::Citation.new(subject.phrase)
      Rails.logger.info(result.score)
      if subject.label == true # actual positive
        if result.detection?
          @buckets['true_positive'] += 1
        else
          @buckets['false_negative'] += 1
        end
      else # actual negative
        if result.detection?
          @buckets['false_positive'] += 1
        else
          @buckets['true_negative'] += 1
        end
      end
      @scores['scored'] += 1

      Rails.logger.info("TP: #{@buckets['true_positive']}   FP: #{@buckets['false_positive']}   FN: #{@buckets['false_negative']}   TN: #{@buckets['true_negative']}")
      Rails.logger.info("\n\n\n")
    end

    @scores['f1'] = (2 * @buckets['true_positive']).to_f / ((2 * @buckets['true_positive']) + @buckets['false_positive'] + @buckets['false_negative'])
  end

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
