class CreateCategory < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.text :note

      t.timestamps
    end
  end

  def up
    create_table :categories do |t|
      t.string :name
      t.text :note

      t.timestamps
    end

    Category.create(name: 'Informational', name: 'Also known as topical or exploratory searches, where the user does not have a specific record in mind')
    Category.create(name: 'Navigational', name: 'Use for things like websites or liaisons, where an in-person question might be "how do I get to..."')
    Category.create(name: 'Transactional', name: 'Also known as a known-item search, where the user has a good idea of what they are looking for, and just need to download it.')
  end

  def down
    drop_table :categories
  end
end
