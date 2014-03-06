Ideaborough::Application.routes.draw do
  root to: "ideas#index"

  resources :accounts, only: [:new, :create]
  resources :ideas, only: [:index, :create, :new, :show]

  devise_for :users, path: "", path_names: { sign_out: "logout", sign_in: "login", sign_up: "signup",  },
             controllers: { invitations: "users/invitations" },
             skip: [:registrations]

  devise_scope :user do
    get "signup",  to: "users/registrations#new", as: :new_user_registration
    post "signup", to: "users/registrations#create", as: :user_registration
    put "invitation/resend", to: "users/invitations#resend", as: :resend_user_invitation
  end
end
