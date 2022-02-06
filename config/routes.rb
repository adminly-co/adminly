Adminly::Engine.routes.draw do

  root 'schema#index'

  get 'schema' => 'schema#schema'
  get 'schema/:table_name' => 'schema#show'

  post '/query' => 'api#query'

  get '/:table_name' => 'api#index'
  get '/:table_name/:id' => 'api#show'
  put '/:table_name/:id' => 'api#update'
  post '/:table_name' => 'api#create'
  delete '/:table_name/:id' => 'api#destroy'

  post '/:table_name/update_many' => 'api#update_many'
  post '/:table_name/delete_many' => 'api#delete_many'
end
