Spree::Core::Engine.add_routes do
  namespace :admin do
    resources :labels, only: :index
    post 'shipments/:shipment_id/label' => 'labels#create', as: :label
  end
end
