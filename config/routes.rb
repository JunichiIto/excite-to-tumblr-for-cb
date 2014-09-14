Rails.application.routes.draw do
  resources :blog_images

  resources :blog_posts

  root to: 'blog_posts#index'
end
