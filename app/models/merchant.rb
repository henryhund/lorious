class Merchant
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :date_of_birth, :street_address, :postal_code, :locality, :region, :ssn_last4, :routing_number, :account_number, :tos_accepted
  
  validates_presence_of :date_of_birth, :street_address, :postal_code, :locality, :region, :ssn_last4, :routing_number, :account_number, :tos_accepted
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end
end
