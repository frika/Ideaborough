class Account < ActiveRecord::Base
  has_many :users, inverse_of: :account
  has_many :ideas, through: :users

  accepts_nested_attributes_for :users
end
