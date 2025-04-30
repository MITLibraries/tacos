class AddConfidenceToSuggestedPatternsAndResources < ActiveRecord::Migration[7.2]
  def change
    add_column :suggested_patterns, :confidence, :float, default: 0.9
    add_column :suggested_resources, :confidence, :float, default: 0.9
  end
end
