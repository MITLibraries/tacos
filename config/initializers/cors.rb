# Be sure to restart your server when you modify this file.

# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('ORIGINS', '').split(',').map{|t| t.strip}
    resource '/graphql', headers: :any, methods: [:post]
  end
end
