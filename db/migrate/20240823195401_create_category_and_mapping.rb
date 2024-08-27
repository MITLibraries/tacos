class CreateCategoryAndMapping < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.text :note

      t.timestamps
    end

    create_table :mappings do |t|
      t.belongs_to :category
      t.belongs_to :detectinator
      t.float :confidence

      t.timestamps
    end

    create_table :detectinators do |t|
      t.string :name
      t.float :confidence

      t.timestamps
    end

    Category.create(name: 'Informational', note: 'Also known as topical or exploratory searches, where the user does not have a specific record in mind')
    Category.create(name: 'Navigational', note: 'Use for things like websites or liaisons, where an in-person question might be "how do I get to..."')
    Category.create(name: 'Transactional', note: 'Also known as a known-item search, where the user has a good idea of what they are looking for, and just need to download it.')

    Detectinator.create(name: 'DOI', confidence: 0.95)
    Detectinator.create(name: 'ISBN', confidence: 0.8)
    Detectinator.create(name: 'ISSN', confidence: 0.6)
    Detectinator.create(name: 'PMID', confidence: 0.95)
    Detectinator.create(name: 'Journal', confidence: 0.2)
    Detectinator.create(name: 'Suggested Resource', confidence: 0.5)

    Mapping.create(category: Category.where("name = 'Transactional'").first, detectinator: Detectinator.where("name = 'DOI'").first, confidence: 0.95)
    Mapping.create(category: Category.where("name = 'Transactional'").first, detectinator: Detectinator.where("name = 'ISBN'").first, confidence: 0.95)
    Mapping.create(category: Category.where("name = 'Transactional'").first, detectinator: Detectinator.where("name = 'ISSN'").first, confidence: 0.95)
    Mapping.create(category: Category.where("name = 'Transactional'").first, detectinator: Detectinator.where("name = 'PMID'").first, confidence: 0.95)
    Mapping.create(category: Category.where("name = 'Transactional'").first, detectinator: Detectinator.where("name = 'Journal'").first, confidence: 0.2)
    Mapping.create(category: Category.where("name = 'Informational'").first, detectinator: Detectinator.where("name = 'Suggested Resource'").first, confidence: 0.1)
    Mapping.create(category: Category.where("name = 'Navigational'").first, detectinator: Detectinator.where("name = 'Suggested Resource'").first, confidence: 0.3)
    Mapping.create(category: Category.where("name = 'Transactional'").first, detectinator: Detectinator.where("name = 'Suggested Resource'").first, confidence: 0.6)
  end

  def down
    drop_table :categories
    drop_table :mappings
    drop_table :detectinators    
  end
end

