require "sinatra"
require "woocommerce_api"

# See http://woothemes.github.io/woocommerce-rest-api-docs/
# for more information
woocommerce = WooCommerce::API.new("https://tienda.comicgram.io", ENV["WC_CONSUMER_KEY"], ENV["WC_CONSUMER_SECRET"])

# Root
get '/' do
  redirect to("/orders")
end

# Order listing
get '/orders' do  
  @orders = woocommerce.get("orders?filter[limit]=30").parsed_response["orders"]
  erb :orders_index
end

# Action for search form
get '/search' do
  query = params['q']
  redirect to("/orders/search/#{query}")
end

# Here is the main star of the show
get '/orders/search/:codes' do
  codes   = params['codes'].split(',')
  @orders = woocommerce.get("orders?filter[limit]=30").parsed_response["orders"]
  @orders = @orders.select do |order|
    skus  = order["line_items"].map { |line_item| line_item["sku"] }
    !(skus & codes).empty?
  end
  erb :orders_index
end
