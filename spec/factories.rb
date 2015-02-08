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
  sequence(:random_currency) { |n| "#{Faker::Commerce.product_name.split(' ')[0..1].join(' ')} #{Random.rand(100)}" }
  
  factory :bitcoin_rate do
    rate { (Random.rand * 1000 + 1).round(2) }
  end
  
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
    
    amount { currency.denomination_values.sample }
    
    factory :assigned_voucher do
      user
    end
  end
  
  factory :denomination do
    currency
    
    value { [1, 5, 10, 20].sample }
    remote_image_url 'http://upload.wikimedia.org/wikipedia/commons/2/24/Onedolar2009series.jpg'
  end
  
  factory :currency do 
    user
    
    name { generate(:random_currency) }
    remote_icon_url 'http://www.rw-designer.com/icon-detail/11995'
    status Currency::ACTIVE
    expiration_days 30
    symbol '$'
    
    after(:create) do |currency|
      FactoryGirl.create(:denomination, :currency => currency, :value => 1, :remote_image_url => 'http://upload.wikimedia.org/wikipedia/commons/2/24/Onedolar2009series.jpg')
      FactoryGirl.create(:denomination, :currency => currency, :value => 5, :remote_image_url => 'http://currencyguide.eu/usd-en/New_five_dollar_bill.jpg')
      # Takes too long to load these!
      #FactoryGirl.create(:denomination, :currency => currency, :value => 10, :remote_image_url => 'http://upload.wikimedia.org/wikipedia/commons/4/49/US10dollarbill-Series_2004A.jpg')
      #FactoryGirl.create(:denomination, :currency => currency, :value => 20, :remote_image_url => 'https://abagond.files.wordpress.com/2014/01/20-dollar-bill-1981.jpg')
    end
    
    factory :currency_with_vouchers do
      transient do
        num_vouchers 2
      end
      
      after(:create) do |currency, evaluator|
        evaluator.num_vouchers.times do
          FactoryGirl.create(:voucher, :currency => currency, :amount => currency.denomination_values.sample)
        end
      end
    end
  end
    
  factory :balance do
    user
    currency
    
    # This is how to create a valid name dynamically; useful code sample
    #transient do
    #  bal_currency { create(:currency) }
    #end    
    amount 1000
    
    #currency_name { bal_currency.name }
    expiration_date 1.week.from_now
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

    factory :user_with_balances do 
      transient do
        num_balances 2
      end
      
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:balance, evaluator.num_balances, :user => user)
      end
    end

    factory :user_with_vouchers do 
      transient do
        num_vouchers 3
      end
      
      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:assigned_voucher, evaluator.num_vouchers, :user => user)
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
    
    amount 10000
    dollar_amount 1
    comment { generate(:random_phrase) }
    dest_id 14
    
    factory :transaction_with_details do      
      after(:create) do |transaction|
        FactoryGirl.create(:transaction_detail, :transaction_id => transaction.id, :subject_id => transaction.user.id, :target_id => transaction.dest_id, :credit => 10000)
        FactoryGirl.create(:transaction_detail, :transaction_id => transaction.id, :subject_id => transaction.dest_id, :target_id => transaction.user.id, :debit => 10000)
      end
    end
  end
 
  factory :transaction_detail do
    transaction
    
    subject_id 3
    target_id 7
    credit { Random.rand(1000000) }
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
    currency
    
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
