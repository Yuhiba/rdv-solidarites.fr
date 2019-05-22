Rails.application.routes.draw do

  ## ADMIN ##
  namespace :admin do
    resources :pros
    require 'sidekiq/web'
    require 'sidekiq/cron/web'
    mount Sidekiq::Web => '/sidekiq'
    root to: "pros#index"
  end

  ## APP ##
  devise_for :pros, controllers: { registrations: 'pros/registrations' }

  authenticated :pro do
    root to: 'agendas#index', as: :authenticated_root
  end

  {disclaimer: 'mentions_legales', terms: 'cgv' }.each do |k,v|
    get v => "static_pages##{k}"
  end
  get 'accueil_mds' => "welcome#welcome_pro"
  root 'welcome#index'

end
