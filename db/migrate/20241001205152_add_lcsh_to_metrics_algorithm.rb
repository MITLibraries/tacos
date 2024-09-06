class AddLcshToMetricsAlgorithm < ActiveRecord::Migration[7.1]
  def change
    add_column :metrics_algorithms, :lcsh, :integer
  end
end
