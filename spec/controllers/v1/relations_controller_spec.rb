require 'rails_helper'

RSpec.describe V1::RelationsController, type: :controller do

  let(:valid_user_attributes) { FactoryGirl.build(:valid_user).attributes }
  let(:invalid_contact_attributes) { FactoryGirl.build(:invalid_user).attributes }
  let(:valid_contact_attributes) { FactoryGirl.build(:valid_user).attributes }
  let(:valid_new_attributes) { FactoryGirl.build(:valid_user).attributes }
  let(:valid_type_relation) { 'friend' }
  let(:new_type_relation) { 'family' }

  let(:create_basic_relation) {
      user = User.create!(valid_user_attributes)
      contact = User.create!(valid_contact_attributes)
      user.create_relation(valid_type_relation,contact.id)
  }

  let(:valid_session) { {} }

  # strong parameters
  let(:valid_params) {  %w(id created_at updated_at).each do |key|
                          valid_new_attributes.delete(key)
                        end
                        valid_new_attributes
                      }
  let(:invalid_params) { { sql_inject: 'SELECT user;' } }

  describe 'API security' do
    context 'when new contact is created' do
      it {
        User.create!(valid_user_attributes)

        post :create,
          params: {
          user_id: User.first,
          contact: valid_params,
          relation: valid_type_relation,
          session: valid_session
          }

        expect(assigns(:contact)).not_to be_nil
      }
    end

    context 'when old contact is updated' do
      it {  create_basic_relation
            expect_any_instance_of(User).to receive(:update!).with(valid_params)
            expect_any_instance_of(Relation).to receive(:update!).with({_type: new_type_relation})

            put :update,
            params: {
              user_id: User.first,
              id: User.last,
              contact: valid_params,
              relation: new_type_relation,
              session: valid_session
            }
          }
    end

    context 'when a hacker tries to make sql_injection' do
      it {  User.create!(valid_user_attributes)

            post :create,
            params: {
              user_id: User.first,
              contact: invalid_params,
              session: valid_session
            }

            expect(response).to have_http_status(:unprocessable_entity)
          }
    end
  end

  # CRUD
  describe "GET #index" do
    # callback
    it { should use_before_action(:set_user) }
    it { should use_before_action(:filter_contacts) }

    context 'with a valid user_id' do
      it "returns a success response" do
        create_basic_relation

        get :index, params: {
          user_id: User.first},
          session: valid_session

        expect(response).to be_success
      end
    end

    context 'with a invalid user_id' do
      it "returns a not found message" do
        create_basic_relation

        get :index, params: {
          user_id: 8_000},
          session: valid_session

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with a default filter setted' do
      it "should render a JSON with all contacts" do
        create_basic_relation

        get :index, params: {
          user_id: User.first},
          session: valid_session

        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body).count).to eq(User.first.contacts.count)
        expect(
          JSON.parse(response.body)).
          to eq([User.last.as_json(:except => [:created_at,:updated_at]).
          merge!("relation" => Relation.first._type)]
        )
      end
    end

    context 'with a relation filter setted' do
      it "should render a filtered JSON contact list" do
        create_basic_relation
        type = Relation.first._type
        relation_method = type == 'family' ? type : type.pluralize

        get :index, params: {
          user_id: User.first,
          relation: type},
          session: valid_session

        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body).count).to eq(User.first.send(relation_method).count)
        expect(
          JSON.parse(response.body)).
          to eq([User.last.as_json(:except => [:created_at,:updated_at]).
          merge!("relation" => type)]
        )
      end
    end
  end

  describe "GET #show" do
    # callback
    it { should use_before_action(:set_user) }
    it { should use_before_action(:set_contact) }

    context 'with a valid user_id and contact_id' do
      it "returns a success response" do
        create_basic_relation

        get :show, params: {
          user_id: User.first,
          id: User.last},
          session: valid_session

        expect(response).to be_success
        expect(
          JSON.parse(response.body)).
          to eq(User.last.as_json(:except => [:created_at,:updated_at]).
          merge("relation" => Relation.first._type)
        )
      end
    end

    context 'with a invalid user_id or contact_id' do
      it "returns a not found message" do
        create_basic_relation

        get :show, params: {
          user_id: 8_000,
          id: 2_000},
          session: valid_session

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #create" do
    # callback
    it { should use_before_action(:set_user) }

    context "with valid params" do
      it "creates new relations (direct and inverse) between user and contact" do
        User.create!(valid_user_attributes)

        expect {
          post :create, params: {
            user_id: User.first,
            contact: valid_contact_attributes,
            relation: valid_type_relation},
            session: valid_session
        }.to change(Relation, :count).by(2)
      end

      it "renders a JSON response with the new contact serialized" do
        User.create!(valid_user_attributes)

        post :create, params: {
          user_id: User.first,
          contact: valid_contact_attributes,
          relation: valid_type_relation},
          session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(
          JSON.parse(response.body)).
          to eq(User.last.as_json(:except => [:created_at,:updated_at]).
          merge("relation" => Relation.last._type)
        )
        expect(response.location).to eq(v1_user_contact_url(user_id:User.first,id:User.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new user" do
        User.create!(valid_user_attributes)

        post :create, params: {
          user_id: User.first,
          contact: invalid_contact_attributes,
          relation: valid_type_relation},
          session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with a contact duplicated" do
      it "renders a JSON response with duplicate user" do
        User.create!(valid_user_attributes)
        User.create!(valid_contact_attributes)

        post :create, params: {
          user_id: User.first,
          contact: User.last.attributes,
          relation: valid_type_relation},
          session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "PUT #update" do
    # callbacks
    it { should use_before_action(:set_user) }
    it { should use_before_action(:set_contact) }

    context "with valid params" do

      it "updates the requested user" do
        create_basic_relation
        user = User.last
        old_name = user.name

        put :update, params: {
          user_id: User.first,
          id: User.last,
          contact: valid_new_attributes,
          relation: Relation.first._type},
          session: valid_session
        user.reload
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        expect(user.created_at).not_to eq(user.updated_at)
        expect(JSON.parse(response.body)['name']).not_to eq(old_name)
      end

      it "renders a JSON response with the user" do
        create_basic_relation

        put :update, params: {
          user_id: User.first,
          id: User.last,
          contact: valid_new_attributes,
          relation: Relation.first._type},
          session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
        expect(
          JSON.parse(response.body)).
          to eq(User.last.as_json(:except => [:created_at,:updated_at]).
          merge("relation" => Relation.last._type)
        )
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the user" do
        create_basic_relation

        put :update, params: {
          user_id: User.first,
          id: User.last,
          contact: invalid_contact_attributes,
          relation: Relation.first._type},
          session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe "DELETE #destroy" do
    # callbacks
    it { should use_before_action(:set_user) }
    it { should use_before_action(:set_contact) }

    context 'with a valid user_id and contact_id' do
      it "destroys the requested relation between user and contact" do
        create_basic_relation

        expect(response).to be_success
        expect {
          delete :destroy, params: {
            user_id: User.first,
            id: User.last},
            session: valid_session
        }.to change(Relation, :count).by(-2)
      end
    end

    context 'with a invalid user_id or contact_id' do
      it "returns a not found message" do
        create_basic_relation

        delete :destroy, params: {
          user_id: 1_000,
          id: 999},
          session: valid_session

        expect(response).to have_http_status(:not_found)
      end
    end
  end

end
