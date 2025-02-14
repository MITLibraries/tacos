class AddSuggestedResourceToTerms < ActiveRecord::Migration[7.1]
  def change
    add_reference :terms, :suggested_resource
    add_foreign_key :terms, :suggested_resources, on_delete: :nullify
  end
end
