class GradesToTen < ActiveRecord::Migration

  def self.up
    Opinion.find(:all).each { |o|
      o.rating = o.rating*2 -1 if o.rating
      o.save
      }
  end

  def self.down
    Opinion.find(:all).each { |o|
      o.rating = o.rating/2 if o.rating
      o.save
      }
  end
  
end

