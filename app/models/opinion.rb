class Opinion < ActiveRecord::Base
  belongs_to :user
  belongs_to :movie
end

