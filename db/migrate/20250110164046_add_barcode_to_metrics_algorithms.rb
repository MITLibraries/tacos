class AddBarcodeToMetricsAlgorithms < ActiveRecord::Migration[7.1]
  def change
    add_column :metrics_algorithms, :barcode, :integer
  end
end
