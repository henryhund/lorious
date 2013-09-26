FactoryGirl.define do
  
  factory :user do
    sequence(:email) { |n| "sample#{n}@gmail.com" }
    name "name"
    password "password123"
    tag_line "TagLine"
    bio "Bio"
    location "Location"
    website "Website"
  end

  factory :expert do
    sequence(:email) { |n| "sample#{n}@gmail.com" }
    name "name"
    password "password123"
    type "Expert"
    tag_line "TagLine"
    bio "Bio"
    location "Location"
    website "Website"
  end

end
