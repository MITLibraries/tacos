class CreateMetricsAlgorithms < ActiveRecord::Migration[7.1]
  def change
    create_table :metrics_algorithms do |t|
      t.date :month
      t.integer :doi
      t.integer :issn
      t.integer :isbn
      t.integer :pmid
      t.integer :unmatched
      t.timestamps
    end
  end
end
