class CreateFeeds < ActiveRecord::Migration[5.0]
  def change
    create_table :feeds do |t|
      t.string :url
      t.time :last_updated_at
      t.string :title

      t.timestamps
    end
  end
end
