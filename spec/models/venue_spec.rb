# == Schema Information
#
# Table name: venues
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  name                  :string(255)      not null
#  address_1             :string(255)
#  address_2             :string(255)
#  city                  :string(255)
#  state                 :string(255)
#  zipcode               :integer
#  website               :string(255)
#  facebook              :string(255)
#  twitter               :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  slug                  :string(255)
#  main_image            :string(255)
#  main_image_processing :boolean
#  activity_type_id      :integer          default(1), not null
#

require 'rails_helper'

RSpec.describe Venue, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
