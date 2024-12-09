class RemoveFlagFromConfirmations < ActiveRecord::Migration[7.1]
  def change
    remove_column :confirmations, :flag, :boolean
  end
end
