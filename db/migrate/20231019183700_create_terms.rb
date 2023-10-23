class CreateTerms < ActiveRecord::Migration[7.1]
  def change
    create_table :terms do |t|
      t.string :phrase, index: { unique: true, name: 'unique_phrase' }
      t.timestamps
    end

  end
end
