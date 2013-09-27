FactoryGirl.define do
  
  factory :user do
    sequence(:email) { |n| "user#{n}@email.com" }
    name "name"
    password "password123"
    tag_line "TagLine"
    bio "Bio"
    location "Location"
    website "Website"
  end

  factory :expert do
    sequence(:email) { |n| "expert#{n}@email.com" }
    name "name"
    password "password123"
    type "Expert"
    tag_line "TagLine"
    bio "Bio"
    location "Location"
    website "Website"
  end

end
