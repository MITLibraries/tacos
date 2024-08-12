class AddSuggestedResourceExactToMetricsAlgorithm < ActiveRecord::Migration[7.1]
  def change
    add_column :metrics_algorithms, :suggested_resource_exact, :integer
  end
end
