Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :captures, except: [:destroy, :update]
    end
  end
end
