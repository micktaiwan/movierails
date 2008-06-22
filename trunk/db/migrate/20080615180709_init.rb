class Init < ActiveRecord::Migration

  def self.up
    create_table :users do |table|
      table.column :name, :string
      table.column :email, :string, :null => false
      table.column :password, :string, :limit => 40, :null => false
      table.column :lost_key, :string
      table.column :last_login, :datetime
      table.column :created_at, :datetime
    end
      
    create_table :movies do |table|
      table.column :title, :string, :null => false
      table.column :year, :string
      table.column :director, :string
      table.column :created_at, :datetime
    end
      
    create_table :opinions do |table|
      table.column :movie_id, :integer
      table.column :user_id, :integer
      table.column :created_at, :datetime
      table.column :saw_on, :date
      table.column :comment, :text
      table.column :rating, :integer
    end
      
    create_table :urls do |table|
      table.column :movie_id, :integer
      table.column :url, :string
      table.column :created_at, :datetime
    end
      
  end

  def self.down
    drop_table :users
    drop_table :movies
    drop_table :opinions
    drop_table :urls
  end
end

