require "rails_helper"

RSpec.describe V1::RelationsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/v1/users/1/contacts").to route_to("v1/relations#index", :user_id => "1")
    end

    it "routes to #show" do
      expect(:get => "/v1/users/1/contacts/1").to route_to("v1/relations#show", :user_id => "1", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/v1/users/1/contacts").to route_to("v1/relations#create", :user_id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/v1/users/1/contacts/1").to route_to("v1/relations#update", :user_id => "1", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/v1/users/1/contacts/1").to route_to("v1/relations#update", :user_id => "1", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/v1/users/1/contacts/1").to route_to("v1/relations#destroy", :user_id => "1", :id => "1")
    end
  end
end