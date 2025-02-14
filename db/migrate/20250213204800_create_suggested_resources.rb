class CreateSuggestedResources < ActiveRecord::Migration[7.1]
  def change
    create_table :suggested_resources do |t|
      t.string :title
      t.string :url

      t.timestamps
    end
  end
end
