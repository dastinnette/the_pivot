class Category < ActiveRecord::Base
  has_many :stache_categories
  has_many :staches, through: :stache_categories
end
