FactoryGirl.define do
  
  factory :user do
    sequence(:email) { |n| "sample#{n}@gmail.com" }
    name "name"
    password "password123"
  end

end
