class AddJournalExactToMetricsAlgorithm < ActiveRecord::Migration[7.1]
  def change
    add_column :metrics_algorithms, :journal_exact, :integer
  end
end
