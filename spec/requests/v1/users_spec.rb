require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "v1/users" do
    it "works! (now write some real specs)" do
      get v1_users_path
      expect(response).to have_http_status(200)
    end
  end
end
