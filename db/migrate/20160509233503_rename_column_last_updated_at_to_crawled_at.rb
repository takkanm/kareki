class RenameColumnLastUpdatedAtToCrawledAt < ActiveRecord::Migration[5.0]
  def change
    rename_column :feeds, :last_updated_at, :crawled_at
  end
end
