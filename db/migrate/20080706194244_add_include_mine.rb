class AddIncludeMine < ActiveRecord::Migration
  def self.up
    add_column :users, :include_mine, :boolean, :default => 0
  end

  def self.down
    remove_column :users, :include_mine
  end
end
