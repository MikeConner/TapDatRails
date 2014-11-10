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
  sequence(:random_currency) { |n| "#{Faker::Commerce.product_name.split(' ')[0..1].join(' ')} Pts" }
  
  factory :opportunity do
    email { generate(:random_email) }
    name { generate(:random_name) }
    location { generate(:random_city) }
  end
  
  factory :nickname do
    column { [1,2].sample }
    word { generate(:random_english_word) }
  end
  
  factory :voucher do
    currency
    
    amount { YAML::load(currency.denominations).sample }
  end
  
  factory :currency do 
    user
    
    name { generate(:random_currency) }
    denominations { YAML.dump([1, 2, 5, 10, 20]) }
    remote_icon_url 'http://favicon-generator.org/favicons/2014-11-09/63f9acfc66d75ec8207fe51c83556d8b.ico'
    status Currency::ACTIVE
    expiration_days 30
    
    factory :currency_with_vouchers do
      transient do
        num_vouchers 2
      end
      
      after(:create) do |currency, evaluator|
        evaluator.num_vouchers.times do
          FactoryGirl.create(:voucher, :currency => currency, :amount => YAML.load(currency.denominations).sample)
        end
      end
    end
  end
    
  factory :balance do
    user
    
    transient do
      bal_currency { create(:currency) }
    end    
    
    currency_name { bal_currency.name }
    expiration_date 1.week.from_now
    
    factory :balance_with_vouchers do
      transient do
        num_vouchers 3
      end
      
      after(:create) do |balance, evaluator|
        evaluator.num_vouchers.times do
          bal_currency = FactoryGirl.create(:currency)
          
          FactoryGirl.create(:voucher, :currency => bal_currency, :balance => balance, 
                             :amount => YAML.load(bal_currency.denominations).sample)
        end
      end
    end
  end
  
  factory :user do
    name { generate(:random_phrase) }
    email { generate(:random_email) }
    password { generate(:random_phrase) }
    phone_secret_key { SecureRandom.hex(8) }
    inbound_btc_address { generate(:random_bitcoin_address) }
    outbound_btc_address { generate(:random_bitcoin_address) }
    satoshi_balance { (SecureRandom.random_number * 10000000).round }
    
    factory :user_with_currencies do 
      transient do
        num_currencies 2
      end
      
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:currency, evaluator.num_currencies, :user => user)
      end
    end
    
    factory :user_with_tags do
      transient do
        num_tags 5
      end
      
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:nfc_tag, evaluator.num_tags, :user => user)
      end
    end
    
    factory :user_with_transactions do
      transient do
        num_tx 2
      end
      
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:transaction, evaluator.num_tx, :user => user)
      end
    end
    
    factory :user_with_details do
      transient do
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
    threshold { Random.rand(1000) }
  end
  
  factory :nfc_tag do
    user
    
    tag_id { SecureRandom.hex(5) }
    name "Tag name"
    
    factory :nfc_tag_with_currency do
      currency
    end
    
    factory :nfc_tag_with_payloads do
      transient do
        num_payloads 3
      end
      
      after(:create) do |nfc_tag, evaluator|
        FactoryGirl.create_list(:payload, evaluator.num_payloads, :nfc_tag => nfc_tag)
      end  
    end
  end
end
