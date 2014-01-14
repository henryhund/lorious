class Problem < ActiveRecord::Base
  #has_and_belongs_to_many :requests
  
  validates_uniqueness_of :value, :case_sensitive => false
end
