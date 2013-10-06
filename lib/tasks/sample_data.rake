namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    require 'populator'
    require 'acts-as-taggable-on'
    
    [Expert, Availability].each(&:delete_all)
    
    Expert.populate(200) do |expert|
      name  = Faker::Name.name
      expert.first_name = name.split(' ').first
      expert.last_name =  name.split(' ').last
      expert.email = Faker::Internet.email
      expert.encrypted_password = "password"
      expert.bio = Populator.sentences(5..10)
      expert.location = Faker::Address.city + ',' + Faker::Address.state_abbr
    end
    
    Expert.all.each do |expert|
      tags = ["Ruby", "C++", "Java", "PostgreSQL", ".NET", "MySql", "PHP", "Phython","Perl","BASIC","Matlab","C#","Pascal","Rails", "Stripe", "API" ,"Node.js"]
      5.times do 
        expert.skill_list.add tags[rand(tags.length)]  
      end
      
      expert.set_availability([{"start_time" => 30, "end_time" => 60}, {"start_time" => 180, "end_time" => 210}], 120) 
      expert.availability.hourly_cost =  rand * (10-5) + 5.0
      expert.availability.save
      #expert.location = 'St Pancras Station, London'
      expert.save
    end
    
    #Need to add ratings for Experts and Profile Image URL
  end
end