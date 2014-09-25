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
  sequence(:random_url) { |n| "http://www." + Faker::Internet.domain_name }
  sequence(:random_sentences) { |n| Faker::Lorem.sentences.join(' ') }
  sequence(:random_bitcoin_address) { |n| Faker::Bitcoin.address }
  sequence(:sequential_tag) { |n| "Tag #{n}"}
  
  factory :opportunity do
    email { generate(:random_email) }
    name { generate(:random_name) }
    location { generate(:random_city) }
  end
  
  factory :nickname do
    column { [1,2].sample }
    word { generate(:random_english_word) }
  end
  
  factory :user do
    name { generate(:random_phrase) }
    email { generate(:random_email) }
    password { generate(:random_phrase) }
    phone_secret_key { SecureRandom.hex(8) }
    inbound_btc_address { generate(:random_bitcoin_address) }
    outbound_btc_address { generate(:random_bitcoin_address) }
    satoshi_balance { (SecureRandom.random_number * 10000000).round }
    
    factory :user_with_tags do
      ignore do
        num_tags 5
      end
      
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:nfc_tag, evaluator.num_tags, :user => user)
      end
    end
    
    factory :user_with_transactions do
      ignore do
        num_tx 2
      end
      
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:transaction, evaluator.num_tx, :user => user)
      end
    end
    
    factory :user_with_details do
      ignore do
        num_tx 2
      end
      
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:transaction_with_details, evaluator.num_tx, :user => user)
      end
    end
  end

  factory :transaction do
    user
    nfc_tag
    payload
    
    satoshi_amount 10000
    dollar_amount 1
    comment { generate(:random_phrase) }
    dest_id 14
    
    factory :transaction_with_details do      
      after(:create) do |transaction|
        FactoryGirl.create(:transaction_detail, :transaction => transaction, :subject_id => transaction.user.id, :target_id => transaction.dest_id, :credit_satoshi => 10000)
        FactoryGirl.create(:transaction_detail, :transaction => transaction, :subject_id => transaction.dest_id, :target_id => transaction.user.id, :debit_satoshi => 10000)
      end
    end
  end
 
  factory :transaction_detail do
    transaction
    
    subject_id 3
    target_id 7
    credit_satoshi { Random.rand(1000000) }
    conversion_rate { Random.rand * 3 }
  end
  
  factory :payload do
    nfc_tag
    
    uri { generate(:random_url) }
    content { generate(:random_sentences) }
    threshold { Random.rand(100) }
  end
  
  factory :nfc_tag do
    user
    
    tag_id { SecureRandom.hex(5) }
    name "Tag name"
    
    factory :nfc_tag_with_payloads do
      ignore do
        num_payloads 3
      end
      
      after(:create) do |nfc_tag, evaluator|
        FactoryGirl.create_list(:payload, evaluator.num_payloads, :nfc_tag => nfc_tag)
      end  
    end
  end
end
