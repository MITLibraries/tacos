class CreateValidations < ActiveRecord::Migration[7.1]
  def change
    create_table :validations do |t|
      t.references :validatable, polymorphic: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :judgement

      t.timestamps
    end

    add_index :validations, [:validatable_id, :validatable_type, :user_id], unique: true

    add_reference :detections, :validatable, polymorphic: true
    add_reference :categorizations, :validatable, polymorphic: true
  end
end
