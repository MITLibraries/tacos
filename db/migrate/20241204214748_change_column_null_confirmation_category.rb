class ChangeColumnNullConfirmationCategory < ActiveRecord::Migration[7.1]
  def change
    change_column_null :confirmations, :category_id, false, Category.find_by(name: 'Flagged').id
  end
end
