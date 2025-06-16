class AddLabelToTerms < ActiveRecord::Migration[7.2]
  def change
    add_column :terms, :label, :boolean
  end
end
