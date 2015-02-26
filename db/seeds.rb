# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'nickname_generator'

# Assuming tough guy generator, which doesn't need external files to intiialize
raise 'Column assumption violated' if NICKNAME_GENERATORS[NicknameGenerator::TOUGH_GENERATOR].nil?

first_name_col = NICKNAME_GENERATORS[NicknameGenerator::TOUGH_GENERATOR].min
last_name_col = NICKNAME_GENERATORS[NicknameGenerator::TOUGH_GENERATOR].max

raise 'Invalid range' if first_name_col == last_name_col

Nickname.where(:column => first_name_col).delete_all
Nickname.where(:column => last_name_col).delete_all

100.times do
  @first, @last = NicknameGenerator.generate_tough_guy.split

  Nickname.create!(:column => first_name_col, :word => @first)
  Nickname.create!(:column => last_name_col, :word => @last)
end

resolved_file = Rails.application.assets.find_asset('nicknames/adjectives.csv')
column_num = 1

raise ArgumentError.new('File not found') if resolved_file.nil?
raise ArgumentError.new('Invalid column number (> 0)') if column_num < 1

Nickname.where(:column => column_num).delete_all

CSV.foreach(resolved_file) do |line|
  Nickname.create(:column => column_num, :word => line[0].strip)
end

resolved_file = Rails.application.assets.find_asset('nicknames/nouns.csv')
column_num = 2

raise ArgumentError.new('File not found') if resolved_file.nil?
raise ArgumentError.new('Invalid column number (> 0)') if column_num < 1

Nickname.where(:column => column_num).delete_all

CSV.foreach(resolved_file) do |line|
  Nickname.create(:column => column_num, :word => line[0].strip)
end

arash = User.create(:email => 'arash@tapdatapp.co', :password => 'MonkeY', :password_confirmation => 'MonkeY', :role => User::ADMIN_ROLE,
                     :name => NicknameGenerator.generate_nickname, :phone_secret_key => SecureRandom.hex(8))

jeff = User.create!(:email => 'jeff@tapdatapp.co', :password => 'MonkeY', :password_confirmation => 'MonkeY', :role => User::ADMIN_ROLE,
                     :name => NicknameGenerator.generate_nickname, :phone_secret_key => SecureRandom.hex(8))

katherine = User.create!(:email => 'katherine@tapdatapp.co', :password => 'MonkeY', :password_confirmation => 'MonkeY', :role => User::ADMIN_ROLE,
                     :name => NicknameGenerator.generate_nickname, :phone_secret_key => SecureRandom.hex(8))

bill = User.create!(:email => 'bill@tapdatapp.co', :password => 'MonkeY', :password_confirmation => 'MonkeY', :role => User::ADMIN_ROLE,
                     :name => NicknameGenerator.generate_nickname, :phone_secret_key => SecureRandom.hex(8))

cc = arash.currencies.create!(:name => 'Captain Coin', :remote_icon_url => 'http://img3.wikia.nocookie.net/__cb20140501181347/creepypasta/images/f/f6/Grumpy_Cat.jpg', expiration_days: 100019, reserve_balance: 15400)                     
cc.denominations.create(:value => 1, :remote_image_url => 'http://s3.amazonaws.com/assets.prod.vetstreet.com/63/900e00040c11e28ae7005056ad4734/file/cat-claw-flickr-335sm092112.jpg', :caption => "Claw")                                         
cc.denominations.create(:value => 5, :remote_image_url => 'http://s3.amazonaws.com/assets.prod.vetstreet.com/10/8507f0bf9d11e18fa8005056ad4734/file/cat%20claws%20135046624.jpg', :caption => "Paw") 

t1 = arash.nfc_tags.create(:tag_id => 'e4e3a6bbfc', :name => 'Toad', :currency_id => cc.id)
t1.payloads.create(:content => 'Tapped!', :remote_payload_image_url => 'https://tapyapa.s3.amazonaws.com/f193i03ancl52rot')
t2 = arash.nfc_tags.create(:tag_id => 'e233de8d30', :name => 'Frog', :currency_id => cc.id)
t2.payloads.create(:content => 'Just paid for my coffee!', :remote_payload_image_url => 'https://tapyapa.s3.amazonaws.com/zp9vip4n39y5gqf3.jpg')

cc.vouchers.create(:uid => "4167f884", :amount => 1800)
cc.vouchers.create(:uid => "ce963f33", :amount => 800)

cc.single_code_generators.create(:code => 'BADKITTY', :value => 100)

kb = jeff.currencies.create!(:name => 'Kennywood Bucks', :remote_icon_url => 'http://amusementparkauthority.com/park_index/american_parks/kennywood/images/logo.jpg', expiration_days: 9999, reserve_balance: 90000, :symbol => 'K')                     
kb.denominations.create(:value => 1, :remote_image_url => 'http://madaboutwords.com/wp-content/uploads/2010/05/one.png', :caption => "1 ride")
kb.denominations.create(:value => 5, :remote_image_url => 'http://2.bp.blogspot.com/-OKebfAWWfZo/UN4VC1kazKI/AAAAAAAABSQ/dQ-VUcbdZAU/s1600/five.png', :caption => "Half Day")
kb.denominations.create(:value => 10, :remote_image_url => 'http://jasontheodor.com/wp-content/uploads//2012/04/ten.png', :caption => "Full Day")

t3 = jeff.nfc_tags.create(:tag_id => 'd14e4ea59b', :name => 'Lizard', :currency_id => kb.id)
t3.payloads.create(:content => 'Tapped!', :remote_payload_image_url => 'https://s3.amazonaws.com/tapyapa/jm12s0doq7nq27o6.jpg')

kb.vouchers.create(:uid => "4d8241d8", :amount => 1800)
kb.vouchers.create(:uid => "8188069c", :amount => 800)
kb.vouchers.create(:uid => "ef96fda2", :amount => 8000)

kb.single_code_generators.create(:code => 'FEB2015', :value => 100)

uh = katherine.currencies.create!(:name => 'Unicorn Horns', :remote_icon_url => 'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcSh1BdXvvarNb2St8uEmB_W1CjfQqOD2RIi2srTqCWL3cmDcw103LfvFB0', expiration_days: 9999, reserve_balance: 995000, :symbol => 'u')                     
uh.denominations.create(:value => 1, :remote_image_url => 'http://madaboutwords.com/wp-content/uploads/2010/05/one.png', :caption => "1 horn")
uh.denominations.create(:value => 5, :remote_image_url => 'http://2.bp.blogspot.com/-OKebfAWWfZo/UN4VC1kazKI/AAAAAAAABSQ/dQ-VUcbdZAU/s1600/five.png', :caption => "Mane Event")
uh.denominations.create(:value => 10, :remote_image_url => 'http://jasontheodor.com/wp-content/uploads//2012/04/ten.png', :caption => "Rainbow Taster")

t4 = katherine.nfc_tags.create(:tag_id => 'c97a991dcc', :name => 'Coelacanth', :currency_id => uh.id)
t4.payloads.create(:content => 'Tapped Dat!', :remote_payload_image_url => 'https://s3.amazonaws.com/tapyapa/u11kqxskgtmu8fom.jpg')

uh.vouchers.create(:uid => "a769496d", :amount => 1000)
uh.vouchers.create(:uid => "56293897", :amount => 200)
uh.vouchers.create(:uid => "f960ae47", :amount => 300)
uh.vouchers.create(:uid => "24884269", :amount => 400)
uh.vouchers.create(:uid => "2f75aa40", :amount => 500)

uh.single_code_generators.create(:code => 'HORNY', :value => 500)

tt = bill.currencies.create!(:name => 'Terrible Token', :remote_icon_url => 'http://upload.wikimedia.org/wikipedia/commons/e/e5/Original-terrible-towel.jpg', expiration_days: 9999, reserve_balance: 995000)                     
tt.denominations.create(:value => 1, :remote_image_url => 'http://madaboutwords.com/wp-content/uploads/2010/05/one.png', :caption => "First down")
tt.denominations.create(:value => 5, :remote_image_url => 'http://2.bp.blogspot.com/-OKebfAWWfZo/UN4VC1kazKI/AAAAAAAABSQ/dQ-VUcbdZAU/s1600/five.png', :caption => "Field Goal")
tt.denominations.create(:value => 10, :remote_image_url => 'http://jasontheodor.com/wp-content/uploads//2012/04/ten.png', :caption => "Touchdown")

t5 = bill.nfc_tags.create(:tag_id => 'd17f665ec2', :name => 'Listrosaur', :currency_id => tt.id)
t5.payloads.create(:content => 'Tapnological!', :remote_payload_image_url => 'https://s3.amazonaws.com/tapyapa/slcixyc4tcpw0nwz.jpg')
     
tt.vouchers.create(:uid => "4beefdca", :amount => 500)
tt.vouchers.create(:uid => "c9df1e77", :amount => 500)
tt.vouchers.create(:uid => "f748eb5d", :amount => 500)
tt.vouchers.create(:uid => "2b245051", :amount => 500)
tt.vouchers.create(:uid => "bd0ccb78", :amount => 500)

tt.single_code_generators.create(:code => 'DOUBLE-YOI', :value => 1000)
