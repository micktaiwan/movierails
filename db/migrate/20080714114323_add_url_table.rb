class AddUrlTable < ActiveRecord::Migration
  def self.up
    create_table :urls do |table|
      table.column :movie_id, :integer
      table.column :user_id, :integer
      table.column :created_at, :datetime
      table.column :name, :string
      table.column :url, :string
    end
  end

  def self.down
    drop_table :urls
  end
end

