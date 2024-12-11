class ChangeColumnNullConfirmationCategory < ActiveRecord::Migration[7.1]
  def change
    Category.find_or_create_by(
      name: 'Flagged',
      description: 'A search which has sensitive information that should be excluded from further processing.'
    )

    change_column_null :confirmations, :category_id, false, Category.find_by(name: 'Flagged').id
  end
end
