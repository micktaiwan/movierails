class Init < ActiveRecord::Migration

  def self.up
    create_table :users do |table|
      table.column :name, :string
      table.column :email, :string, :null => false
      table.column :password, :string, :limit => 32, :null => false
    end
      
    create_table :movies do |table|
      table.column :name, :string, :null => false
      table.column :imdb, :string
      table.column :year, :string
      table.column :director, :string
    end
      
    create_table :movies_users do |table|
      table.column :movie_id, :string
      table.column :user_id, :string
    end
      
  end

  def self.down
    drop_table :users
    drop_table :movies
    drop_table :movies_users
  end
end

