module WebStore
  class API < Grape::API
    version 'v1', using: :path

    format :json
    default_format :json

    helpers do
      def declared_params
        declared(params, include_missing: false)
      end
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      message = e.message.gsub(/\s*\[.*\Z/, '')
        Rack::Response.new(
          [{ status_code: 404, message: message }.to_json],
          404,
          { 'Content-Type' => 'application/json' }
        )
    end

    desc "Fetch all products."
    get '/products' do
      Product.all
    end

    desc "Fetch a single product."
    params do
      requires :id
    end
    get '/products/:id' do
      Product.find params[:id]
    end


    group do
      http_basic do |username, password|
        { 'admin' => 'password' }[username] == password
      end

      desc "Create a new product."
      params do
        requires :name
        requires :sku
        optional :price
      end
      post '/products' do
        Product.create! declared_params
      end
    end

    route :any, '*path' do
      status 404
      { status_code: 404, message: "Path not found."}
    end
  end
end
