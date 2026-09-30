class AddSuggestorToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :suggestor, :boolean, default: false
  end
end
