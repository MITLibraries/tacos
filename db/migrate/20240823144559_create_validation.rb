class CreateValidation < ActiveRecord::Migration[7.1]
  def change
    create_table :validations do |t|
      t.integer :categorization_id
      t.boolean :valid_category
      t.boolean :valid_transaction
      t.boolean :valid_information
      t.boolean :valid_navigation
      t.boolean :valid_doi
      t.boolean :valid_isbn
      t.boolean :valid_issn
      t.boolean :valid_pmid
      t.boolean :valid_journal
      t.boolean :valid_suggested_resource
      t.boolean :flag_term

      t.timestamps
    end
  end
end
