namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create!(first_name: "Example",
                 last_name: "User",
                 email: "example@lorious.com",
                 password: "foobarfoo")
    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@lorious.com"
      password  = "password"
      User.create!(first_name: name.split(' ').first,
                   last_name: name.split(' ').last,
                   email: email,
                   password: password)
    end
  end
end