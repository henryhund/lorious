class CreditTransaction < ActiveRecord::Base
  
  belongs_to :transacter, class_name: "User"
  belongs_to :transacted, class_name: "User"
  
  has_one :appointment, foreign_key: "transaction_id", dependent: :destroy
  
  def amount_with_sign
    added ? amount : -amount
  end
  
end
