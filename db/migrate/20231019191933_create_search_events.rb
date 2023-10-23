class CreateSearchEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :search_events do |t|
      t.belongs_to :term
      t.string :source      
      t.timestamps
    end

    add_index :search_events, :source
  end
end
