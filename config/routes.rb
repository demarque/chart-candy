Rails.application.routes.draw do
  resources :candy_charts, only: [:index, :show], controller: "candy_charts"
end
