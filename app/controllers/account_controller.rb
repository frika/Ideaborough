class AccountController < ApplicationController
  def new
    @account = Account.new
    @account.users.build
  end

  def create
    @account = Account.create(account_params)
  end

  private

  def account_params
    params.require(:account)
          .permit(:name, {users_attributes: [:name, :email, :password,
                  :password_confirmation]})
  end
end
