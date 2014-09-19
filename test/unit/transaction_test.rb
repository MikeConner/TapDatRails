# == Schema Information
#
# Table name: transactions
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  nfc_tag_id     :integer
#  payload_id     :integer
#  dest_id        :integer
#  satoshi_amount :integer
#  dollar_amount  :integer
#  comment        :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
