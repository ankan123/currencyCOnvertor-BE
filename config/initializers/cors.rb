Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:3001' # React frontend origin
    resource '*', headers: :any, methods: [:get, :post, :options]
  end
end
