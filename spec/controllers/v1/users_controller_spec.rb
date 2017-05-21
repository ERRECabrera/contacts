require 'rails_helper'

RSpec.describe V1::UsersController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { FactoryGirl.build(:valid_user).attributes }
  let(:invalid_attributes) { FactoryGirl.build(:invalid_user).attributes }
  let(:new_attributes) { FactoryGirl.build(:valid_user).attributes }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  # strong parameters
  let(:valid_params) {  %w(id created_at updated_at).each do |key|
                          valid_attributes.delete(key)
                        end
                        valid_attributes
                      }
  let(:invalid_params) { { user: { sql_inject: 'SELECT user;' } } }

  describe 'API security' do
    context 'when new user is created' do
      it {
           post :create,
           params: {user: valid_params},
           session: valid_session
           expect(assigns(:user)).not_to be_nil
         }
    end

    context 'when old user is updated' do
      it { user = User.create! new_attributes
           expect_any_instance_of(User).to receive(:update!).with(valid_params)
           put :update, params: {id: user.to_param, user: valid_params}, session: valid_session
         }
    end

    context 'when a hacker tries to make sql_injection' do
      it {
            post :create,
            params: invalid_params,
            session: valid_session
            expect(response).to have_http_status(:unprocessable_entity)
         }
    end
  end

  # CRUD
  # describe "GET #index" do
  #   it "returns a success response" do
  #     user = User.create! valid_attributes

  #     get :index, params: {}, session: valid_session
  #     expect(response).to be_success
  #   end
  # end

  describe "GET #show" do
    # callback
    it { should use_before_action(:set_user) }

    it "returns a success response" do
      user = User.create! valid_attributes

      get :show, params: {id: user.to_param}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new User" do
        expect {
          post :create, params: {user: valid_attributes}, session: valid_session
        }.to change(User, :count).by(1)
      end

      it "renders a JSON response with the new user serialized" do
        post :create, params: {user: valid_attributes}, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        user_last_sanitized = ['created_at',]
        expect(
          JSON.parse(response.body)).
          to eq(User.last.as_json(:except => [:created_at,:updated_at]).
          merge!("relation" => "undefined")
        )
        expect(response.location).to eq(v1_user_url(User.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new user" do
        post :create, params: {user: invalid_attributes}, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "PUT #update" do
    # callbacks
    it { should use_before_action(:set_user) }

    context "with valid params" do

      it "updates the requested user" do
        user = User.create! valid_attributes
        old_name = user.name

        put :update, params: {id: user.to_param, user: new_attributes}, session: valid_session
        user.reload
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        expect(user.created_at).not_to eq(user.updated_at)
        expect(JSON.parse(response.body)['name']).not_to eq(old_name)
      end

      it "renders a JSON response with the user" do
        user = User.create! valid_attributes

        put :update, params: {id: user.to_param, user: valid_attributes}, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the user" do
        user = User.create! valid_attributes

        put :update, params: {id: user.to_param, user: invalid_attributes}, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    # callbacks
    it { should use_before_action(:set_user) }

    it "destroys the requested user" do
      user = User.create! valid_attributes
      expect {
        delete :destroy, params: {id: user.to_param}, session: valid_session
      }.to change(User, :count).by(-1)
    end
  end

  describe 'exception handler' do
    context "when user doesn't exist" do
      subject { get :show, params: {id: '1_000'}, session: valid_session }
      it { is_expected.to have_http_status(:not_found) }
    end

    context "when user is not valid" do
      subject { post :create, params: {user: invalid_attributes}, session: valid_session }
      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context "when raises a bug" do
      let(:user) { User.create! valid_attributes }

      before {
        V1::UsersController.redefine_method('destroy') do
          raise Exception
        end
      }
      after {
        V1::UsersController.redefine_method('destroy') do
          @user.destroy
        end
      }

      subject { delete :destroy, params: {id: user.to_param}, session: valid_session }
      it { is_expected.to have_http_status(:internal_server_error) }
    end
  end

end
