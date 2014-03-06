class Users::RegistrationsController < Devise::RegistrationsController
  def create
    @user = User.new(user_params)

    if @user.save
      set_flash_message :notice, :signed_up
      sign_up(:user, @user)
      respond_with @user, location: root_path
    else
      clean_up_passwords @user
      respond_with @user
    end
  end

  private

  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation)
  end
end
