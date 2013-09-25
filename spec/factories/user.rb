FactoryGirl.define do
  
  factory :user do
    sequence(:email) { |n| "sample#{n}@gmail.com" }
    name "name"
    password "password123"
  end

  factory :expert do
    sequence(:email) { |n| "sample#{n}@gmail.com" }
    name "name"
    password "password123"
    type "Expert"
  end

end
