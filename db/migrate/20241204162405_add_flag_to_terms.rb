class AddFlagToTerms < ActiveRecord::Migration[7.1]
  def change
    add_column :terms, :flag, :boolean
  end
end
