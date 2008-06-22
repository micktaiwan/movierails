class Init < ActiveRecord::Migration

  def self.up
    create_table :users do |table|
      table.column :name, :string
      table.column :email, :string, :null => false
      table.column :password, :string, :limit => 40, :null => false
      table.column :lost_key, :string
      table.column :last_login, :datetime
    end
      
    create_table :movies do |table|
      table.column :name, :string, :null => false
      table.column :year, :string
      table.column :director, :string
    end
      
    create_table :movies_users do |table|
      table.column :movie_id, :integer
      table.column :user_id, :integer
    end
      
    create_table :urls do |table|
      table.column :movie_id, :integer
      table.column :url, :string
    end
      
  end

  def self.down
    drop_table :users
    drop_table :movies
    drop_table :movies_users
    drop_table :urls
  end
end

