class AddCitationToMetricsAlgorithms < ActiveRecord::Migration[7.1]
  def change
    add_column :metrics_algorithms, :citation, :integer
  end
end
