class WantMail < ActiveRecord::Migration
  def self.up
    add_column :users, :want_mail, :boolean, :default => 1
  end

  def self.down
    remove_column :users, :emai
  end
end
