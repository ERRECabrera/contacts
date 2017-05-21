module V1
  class RelationsController < ApplicationController
    #callbacks
    before_action :set_user
    before_action :set_contact, only: [:show, :update, :destroy]
    before_action :filter_contacts, only: :index

    # constants
    STRONG_PARAMETERS = [ :name, :email, :avatar, :surnames => [], :phones => [] ]

    # GET v1/users/1/contacts
          # v1/users/1/contacts?relation=
          # v1/users/1/contacts?name=
          # v1/users/1/contacts?surnames[]=&surnames[]=
    def index
      json_response(@contacts, user_id: @user.id, status: :ok)
    end

    # GET v1/users/1/contacts/1
    def show
      json_response(@contact, user_id: @user.id, status: :ok)
    end

    # POST v1/users/1/contacts
    def create
      type = params[:relation]
      #take duplicate or create a new user
      @contact =  User.duplicate(contact_params[:name],
                  contact_params[:surnames],
                  contact_params[:email]).first || User.create!(contact_params)
      raise ActiveRecord::RecordInvalid if @user.has_relation?(@contact.id)
      @user.create_relation(type,@contact.id)
      json_response(@contact, user_id: @user.id, status: :created, location: v1_user_contact_url(@user,@contact))
    end

    # PATCH/PUT v1/users/1/contacts/1
    def update
      direct_relation = @user.has_relation?(@contact.id)
      inverse_relation = @contact.has_relation?(@user.id)
      #to avoid raise enum error if params is bad
      type = { _type: params[:relation] || direct_relation._type }
      update_contact = @contact.update!(contact_params)
      update_direct_relation = direct_relation.update!(type)
      update_inverse_relation = inverse_relation.update!(type)
      if update_contact or update_direct_relation or update_inverse_relation
        json_response(@contact, user_id: @user.id, status: :ok)
      end
    end

    # DELETE v1/users/1/contacts/1
    def destroy
      direct_relation = @user.has_relation?(@contact.id)
      inverse_relation = @contact.has_relation?(@user.id)
      direct_relation.destroy
      inverse_relation.destroy
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end

    def set_contact
      @contact = @user.contacts.find(params[:id])
    end

    def filter_contacts
      name = params[:name]
      surnames = params[:surnames]
      @contacts = case params[:relation]
                  when 'family' then @user.family
                  when 'friends' then @user.friends
                  when 'partners' then @user.partners
                  else
                    @user.contacts
                  end
      @contacts = @contacts.named(name) if name
      @contacts = @contacts.surnamed(surnames) if surnames
    end

    def contact_params
      params.require(:contact).permit(STRONG_PARAMETERS)
    end
  end
end
