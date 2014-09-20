FactoryGirl.define do
  sequence(:random_first_name) { |n| Faker::Name.first_name }
  sequence(:random_last_name) { |n| Faker::Name.last_name }
  sequence(:random_name) { |n| Faker::Name.name }
  sequence(:random_email) { |n| Faker::Internet.email }
  sequence(:random_city) { |n| Faker::Address.city }
  sequence(:random_english_word) { |n| Faker::Commerce.product_name.split(' ')[0] }
  sequence(:random_vendor_name) { |n| Faker::Company.name }
  sequence(:random_phrase) { |n| Faker::Company.catch_phrase }
  sequence(:random_word) { |n| Faker::Lorem.word }

  factory :opportunity do
    email { generate(:random_email) }
    name { generate(:random_name) }
    location { generate(:random_city) }
  end
  
  factory :nickname do
    column { [1,2].sample }
    word { generate(:random_english_word) }
  end
end
