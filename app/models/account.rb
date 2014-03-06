# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Account < ActiveRecord::Base
  has_many :users, inverse_of: :account
  has_many :ideas, through: :users

  accepts_nested_attributes_for :users
end
