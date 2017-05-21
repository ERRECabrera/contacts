require "net/http"
require "uri"
require_relative "../spec/factories/factory_helpers.rb"

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#functions
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

def create_contact
  name = Faker::Name.first_name
  return User.create!(
    :name => name,
    :surnames => FactoryHelpers.get_surnames,
    :email => Faker::Internet.free_email(name),
    :phones => FactoryHelpers.get_valid_phones,
    :avatar => $checked ? Base64.strict_encode64(get_cat_img) : nil
  )
end

#global vars
$checked = check?('http://lorempixel.com')
$relation_types = Relation::TYPE_RELATIONS.keys.map!(&:to_s)
$user = User.create!(
  :name => 'Raúl',
  :surnames => ['Cabrera','Medina'],
  :email => 'rauliscoding@gmail.com',
  :phones => ['+34650278300','+34928363270'],
  :avatar => $checked ? Base64.strict_encode64(get_cat_img) : nil
)

25.times do |n|
  begin
    new_contact = create_contact
    type = $relation_types.sample
    $user.create_relation(type,new_contact.id)
  rescue Exception => e
    Rails.logger.info e.message
    next
  end
end