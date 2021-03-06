FactoryGirl.define do
  
  factory :user do
    sequence(:email) { |n| "user#{n}@email.com" }
    first_name "first"
    last_name "last"
    password "password123"
    tag_line "TagLine"
    bio "Bio"
    location "Location"
    website "http://website.com"
    sequence(:username) { |n| "User#{n}" }
    job "expert"
  end

  factory :expert do
    sequence(:email) { |n| "expert#{n}@email.com" }
    first_name "first"
    last_name "last"
    password "password123"
    type "Expert"
    tag_line "TagLine"
    bio "Bio"
    location "Location"
    website "http://website.com"
    sequence(:username) { |n| "Expert#{n}" }
    job "expert"
  end

end
