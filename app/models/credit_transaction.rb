class CreditTransaction < ActiveRecord::Base
  
  belongs_to :transacter, class_name: "User"
  belongs_to :transacted, class_name: "User"
  
  def amount_with_sign
    added ? amount : -amount
  end
  
end
