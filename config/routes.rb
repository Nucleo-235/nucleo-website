Rails.application.routes.draw do
  resources :projects do
    member do
      get 'add_category/:category_id', :action => 'add_category', as: :add_category
      get 'remove_category/:category_id', :action => 'remove_category', as: :remove_category
    end
  end
  resources :partners
  resources :customers

  scope "(:locale)", locale: /pt-BR|en|es/ do
    root to: 'pages#home'
  end
  devise_for :users

  match '*path', via: :all, to: redirect('/')
end
