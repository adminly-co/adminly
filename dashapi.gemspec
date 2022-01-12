require_relative "lib/dash_api/version"

Gem::Specification.new do |spec|
  spec.name        = "dash_api"
  spec.version     = DashApi::VERSION
  spec.authors     = ["Rami Bitar"]
  spec.email       = ["rami@skillhire.com"]
  spec.homepage    = "https://github.com/dash-api/dash-api.git"
  spec.summary     = "REST API for your postgres database."
  spec.description = "Dash is a Rails engine that auto-generates a REST API for your postgres database."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dash-api/dash-api.git"
  spec.metadata["changelog_uri"] = "https://github.com/dash-api/dash-api.git"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 6.1.4.1"
  
  spec.add_dependency "dotenv-rails"
  spec.add_dependency "jwt"
  spec.add_dependency "kaminari"
  spec.add_dependency "ostruct"
  spec.add_dependency "pundit"
  spec.add_dependency "pg"
  spec.add_dependency "pg_search"

end
