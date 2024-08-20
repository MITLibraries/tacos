class AddCategoryToTerm < ActiveRecord::Migration[7.1]
  def change
    add_column :terms, :category, :integer
  end
end
