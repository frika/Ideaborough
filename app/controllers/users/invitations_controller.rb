class Users::InvitationsController < Devise::InvitationsController
  def invite_params
    params.require(:user)
          .permit(:email)
          .merge(account: current_account)
  end
end
