# == Schema Information
#
# Table name: payloads
#
#  id         :integer          not null, primary key
#  nfc_tag_id :integer          not null
#  uri        :string(255)
#  content    :text
#  threshold  :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Payload < ActiveRecord::Base
  attr_accessible :content, :threshold, :uri
  
  belongs_to :nfc_tag
end
