class CreateAggregateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :aggregate_matches do |t|
      t.integer :doi
      t.integer :issn
      t.integer :isbn
      t.integer :pmid
      t.integer :unmatched
      t.timestamps
    end
  end
end
