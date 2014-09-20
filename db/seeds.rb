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
