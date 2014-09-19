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

require 'test_helper'

class PayloadTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
