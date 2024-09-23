# frozen_string_literal: true

class ReportController < ApplicationController
  def index; end

  def algorithm_metrics
    @metrics = if params[:type] == 'aggregate'
                 Metrics::Algorithms.aggregates
               else
                 Metrics::Algorithms.monthlies
               end
  end
end
