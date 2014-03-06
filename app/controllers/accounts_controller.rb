class AccountsController < ApplicationController
  respond_to :html

  def new
    @account = Account.new
    @account.users.build

    respond_with @account
  end

  def create
    @account = Account.new(account_params)

    if @account.save
      sign_in @account.users.first
      respond_with @account, location: root_url
    else
      respond_with @account
    end


  end

  private

  def account_params
    params.require(:account)
          .permit(:name, {users_attributes: [:first_name, :last_name, :email,
                  :role, :password, :password_confirmation]})
  end
end
