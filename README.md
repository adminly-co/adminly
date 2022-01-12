# Dash API
Dash API is a Rails engine that mounts an instant REST API for your Ruby on Rails applications 
using your Postgres database. DashAPI can be queried using a flexible and expressive syntax from URL parameters. 

DashAPI is also designed to be performant, scalable and secure. 

Note: DashAPI is a pre-release product and not yet recommended for any production applications.

## Features
DashAPI is an instant REST API for your Postgres database built using Ruby on Rails. 
DashAPI supports several features out of the box with little or no configuration required:
 - Full-text search
 - Filtering
 - Sorting
 - Selects 
 - Associations
 - Statistics 
 - Pagination
 - JWT token authorization
 - Role-based access control 

DashAPI is designed to help rapidly build fully functional, scalable and secure applications 
by automatically generating REST APIs using any Postgres database. DashAPI also supports 
advanced features including join associations between tables, full-text keyword search using the 
native search capabilities of postgres, and 

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'dash_api'
```

And then execute:
```bash
$ bundle
```

Mount the Dash API by updating your `routes.rb` file:
```
  mount DashApi::Engine, at: "/dash/api"
```

Install the pundit policy
```bash
rails g pundit:install 
```

You can also configure DashApi with an initializer by creating a file at `config/initializers/dash_api.rb`.

```
# Place file at config/initializers/dash_api.rb

DashApi.tap |config|
  config.jwt_secret = ENV['DASH_JWT_SECRET']
end 
```


The DashAPI is now ready. You can view all tables at:
`/dash/api`

You can query a table at:
`/dash/api/<table_name>`

## Requirements

Dash API requires Ruby on Rails and Postgres, and below are recommended versions: 
 - Rails 6+ 
 - Ruby 2.7.4+
 - Postgres 9+ database

## Documentation 

Dash supports a flexible, expressive query syntax using URL parameters to query a Postgres database.

All tables can be queried by passing in the table name to the dash API endpoint where you mounted
the Dash rails engine: 

```
GET /dash/api/<table>
```

Example:

```
GET /dash/api/books 
```

### Schema 

Your database schema is available in order to inspect available tables and column data. 

```
GET /dash/api/schema
```

You can inspect any specific table using the schema endpoint:

```
GET /dash/api/schema/<table_name>
```

Example:
```
GET /dash/api/schema/books
```

### Filtering 

You can filter queries using the pattern 

```
GET /dash/api/table?filters=<resource_field>:<operator>:<value>
```

Example:
Below is an example to find all users with ID less than 10:
```
GET /dash/api/books?filters=id:lt:10 
```
You can also chain filters to support multiple filters that are ANDed together:

```
GET /dash/api/books?filters=id:lt:10,published:eq:true 
```

The currently supported operators are:


```
eq  - Equals
neq - Not equals
gt  - Greater than
gte - Greater than or equal too
lt  - Less than
lte - Less than or equal too
```

### Sorting 

You can sort queries using the pattern:

```
GET /dash/api/table?order=<field>:<asc|desc>
```

Example:

```
GET /dash/api/books?order=title:desc
```

### Pagination

Dash API uses page based pagination. By default results are paginated with 20 results per page. 
You can paginate results with the following query pattern:

```
GET /dash/api/table?page=<page>&per_page=<per_page>
```

Example:
```
GET /dash/api/books?page=2&per_page=10
```

### Select 

Select fields allow you to return only specific fields from a table, similar to the SQL select statement. 
Select fields follows the query pattern:

```
GET /dash/api/table?select=<field>,<field>
```

Example:
You can comma separate the fields to include multiple fields in the response

```
GET /dash/api/books?select=id,title,summary
```

### Full-text search 

DashAPI supports native full-text search capabilities. You can search against all fields of a tables with the 
query syntax:

```
GET /dash/api/table?keywords=<search_terms>
```

Example:
You can find all users that match the search term below. All keywords are URI decoded prior to issuing a search.
```
GET /dash/api/books?keywords=ruby+on+rails
```

Warning: At this time all fields are searchable and using this API which may include any sensitive data in your database.


### Associations 

Dash takes advantage of Ruby on Rails expressive and powerful ORM, ActiveRecord, to 
dymacally infer associations between tables and serialize them. Associations currently 
supported are belongs_to and has_many, and this feature is only available 
for tables that follow strict Rails naming conventions. 

To include a belongs_to table association, use the singular form of the table name:
```
GET /dash/api/books?includes=author
```

To include a has_manay table association, use the plural form of the table name:
```
GET /dash/api/books?includes=reviews 
```

To combine associations together comma seperate the included tables:
```
GET /dash/api/books?includes=author,reviews 
```

### Statistics 

You can perform calculations for the `minimum`, `maximum`, `average` or `count` of any field in a table. 
You may also combine filters or other query parameters to refine results before performing the calculation. 

Maxixum
```
max=<field>
```

Minimum
```
min=<field>
```

Average
```
avg=<field>
```

Count
```
count=<field>
```

Example: 
```
GET /dash/api/books?avg=ratings 
```


### Create

Create table rows:

```
POST /dash/api/<table_name>

Body

{
  <table_name>: {
    field: value,    
    ... 
  }
}
```

### Update

Update table rows by ID:

```
PUT /dash/api/<table_name>/<id>

Body

{
  <table_name>: {
    field: value,    
    ... 
  }
}

```

### Delete

Delete table rows by id:

```
DELETE /dash/api/<table_name>/<id>
```

### Update many 

Bulk update multiple rows by passing in an array of integers the the JSON attributes to update:

```
POST /dash/api/<table_name>/update_many 

Body

{
  ids: [Integer],
  <table_name>: {
    field: value,    
    ... 
  }
}
```

### Delete many 

Bulk delete rows by passing in an array of IDs to delete:

```
POST /dash/api/<table_name>/delete_many 

Body

{
  ids: [Integer]
}
```

### JWT Token Authorization 

The recommended way to secure your API is to use a JWT token. To enable a JWT token, you must first 
specify the JWT secret key in your configuration at `config/initializers/dash_api.rb` 

Dash API is designed to work alongside an existing API or an additional server which handles authentication. This is accomplished by using a shared JWT secret that is to decode the JWT token. 

The JWT decoded object should be a json object and is expected to have a "role" field and a 
corresponding "id" field to identify the ID of the user. 

```
# /config/initializers/dash_api.rb

DashApi.tap do |config|
  config.jwt_secret = ENV['DASH_JWT_SECRET']  
  ...
end 
```

YOu can also disable authentication using the `disable_authentication` option:

```
# /config/initializers/dash_api.rb

DashApi.tap do |config|
  config.disable_authentication = true
  ...
end 
```

### API Authentication 

To authenticate your requests, pass the encoded JWT token in your authorization headers:
```
Authorization: 'Bearer <JWT_TOKEN>'
```

You can also pass the token as a url paramter with every request:
```
/dash/api/...?token=<JWT_TOKEN>
```

The JWT token will also inspect for the `exp` key and if present will only allow requests with valid expiration timestamps. For security purposes it's recommended that you encode your JWT tokens with an exp  timestamp. 

To setup and test JWT tokens, we recommend you explore [jwt.io](https://jwt.io). 

### Authorization (Pundit) 

DashAPI uses the popular Ruby on Rails [Pundet](https://github.com/varvet/pundit) gem to manage 
the authorization policies. Using pundit, you can restrict access to any table or method within a table
according to "policies" that you define. These policies map to the User object that is passed from the JWT token. 

When you first installed DashAPI, you run the pundit installation generator which creates an `ApplicationPolicy` file in `app/policies.` `ApplicationPolicy` defines all the default policies inherited by all tables in the DashAPI. 

The benefit of using Pundit is that you can easily create an acesss policy or search scope by creating a policy for each table in your database that differs from the default policy. To do this, simple create a ruby class that matches the name of the table class followed by the term "Policy." For example, if you want to create a policy for your `orders` table then you can create a ruby class as follows

```
# Place this file in /app/policies/order_policy.rb

def OrderPolicy < ApplicationPolicy 
   ...   
end 
```

You can then specify the polify for each operation from the API. First, below is a sample policy class used by Pundit without any restrictions in place:

```
class OrderPolicy < ApplicationPolicy 

  def index?
    true 
  end 

  def show? 
    true
  end 

  def update?     
    true 
  end 

  def destroy?
    true 
  end 

  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      scope.all 
    end

    private

    attr_reader :user, :scope
  end
end   
```

### Authorization for scope queries 

One common scenario is to restrict access to all `Orders` that only belong to the current user, unless ther user has role `admin` any have access to all `Orders.` You can easily achieve this by specifying the Scope class `resolve` method:

```
def resolve 
  if @user.role === 'admin' 
    scope.all 
  else 
    scope.where(user_id: @user.id)
  end
end 
```

This will restrict all order results to those that only belong to the current user. Again, the user is the JSON payload that is decoded using the JWT token. For example, the token you encode and decode should have at the very least a unique identifier such as `id` or `uid` and a `role` field:

{
 id: 1,
 first_name: 'John',
 last_name: 'Doe',
 role: 'admin'
}

When this JWT token is passed to Pundit using DashAPI, it will be accessible as `@user` and you can reference any attribute on user such as `@user.id` and `@user.role` within the Pundit policy class. 


### Authorization for CRUD operations

You can also override ride any specific CRUD operation by specifying the policy for that operation. This will allow you to provide access control that changes for `admins` and `users`.

As an example, lets only allow users to be able to delete an order if the order status is a `draft` order, and not an order that as been `paid.`

```
def destroy?
  if @user.role === 'admin'
    true 
  else 
    @user.id === @record.user_id && @record.status === 'draft'
  end 
end 
```

Pundit provides a simple yet powerful way to manage the access control policies of the DashAPI for any table. 


### Serialization 

DashAPI will serialize all data from the API using the `as_json` method on the Active Record object. 

## Contributing
Contributions are welcome by issuing a pull request at our github repository:
https:/github.com/skillhire/dash_api


## License

The gem is available as open source under the terms of the [MIT License](https:/opensource.org/licenses/MIT).
