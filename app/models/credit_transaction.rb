class CreditTransaction < ActiveRecord::Base
  belongs_to :user

  def amount_with_sign
    added ? amount : -amount
  end
end
