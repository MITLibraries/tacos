class AddDetailsToSuggestedResources < ActiveRecord::Migration[8.1]
  def change
    change_column_null :suggested_resources, :title, false
    change_column_null :suggested_resources, :url, false
  end
end
