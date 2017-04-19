# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Test seeds
5.times do
  Post.create(ups: (rand(10) + 5), downs: (rand(10) + 5),
              post_date: Faker::Time.between(5.years.ago, Date.today, :all),
              post_id: ((rand(1000) + 5).to_s + Faker::GameOfThrones.house))
end
