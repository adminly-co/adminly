Adminly::Engine.routes.draw do

  root 'schema#index'

  get 'schema' => 'schema#schema'
  get 'schema/:table_name' => 'schema#show'

  post '/query' => 'api#query'

  get '/:table_name' => 'api#index', defaults: { format: :json }
  get '/:table_name/:id' => 'api#show', defaults: { format: :json }
  put '/:table_name/:id' => 'api#update', defaults: { format: :json }
  post '/:table_name' => 'api#create', defaults: { format: :json }
  delete '/:table_name/:id' => 'api#destroy', defaults: { format: :json }

  post '/:table_name/update_many' => 'api#update_many', defaults: { format: :json }
  post '/:table_name/delete_many' => 'api#delete_many', defaults: { format: :json }
end
