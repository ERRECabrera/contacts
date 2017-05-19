require "net/http"
require "uri"

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user_attributes = {
  :name => nil,
  :surnames => [],
  :email => nil,
  :phones => [],
  :avatar => nil
}

def check?(url)
  uri = URI.parse(url)
  check = Net::Ping::External.new(uri.host)
  check.ping?
end

def get_cat_img
  uri = URI.parse('http://lorempixel.com/400/400/cats/')
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  response.body
end

checked = check?('http://lorempixel.com')

User.create!(
  :name => 'Raúl',
  :surnames => ['Cabrera','Medina'],
  :email => 'rauliscoding@gmail.com',
  :phones => ['+34650278300','+34928363270'],
  :avatar => checked ? Base64.strict_encode64(get_cat_img) : nil
)
