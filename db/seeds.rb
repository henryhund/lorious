# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ first_name: 'Chicago' }, { first_name: 'Copenhagen' }])
#   Mayor.create(first_name: 'Emanuel', city: cities.first)

User.delete_all(['id NOT IN (?)', 1])
user2 = User.create!(first_name: "Pranav 2", password: "asdas12d", email: "a1@a.com")
user3 = User.create!(first_name: "Pranav 3", password: "asdas12d", email: "a2@a.com")
user4 = User.create!(first_name: "Pranav 4", password: "asdas12d", email: "a3@a.com")
user5 = User.create!(first_name: "Pranav 5", password: "asdas12d", email: "a4@a.com")
user6 = User.create!(first_name: "Pranav 6", password: "asdas12d", email: "a5@a.com")
