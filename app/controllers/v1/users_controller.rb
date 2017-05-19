module V1
  class UsersController < ApplicationController
    #callbacks
    before_action :set_user, only: [:show, :update, :destroy]

    # constants
    STRONG_PARAMETERS = [ :name, :email, :avatar, :surnames => [], :phones => [] ]

    # GET v1/users
    def index
      @users = User.all

      json_response(@users, status: :ok)
    end

    # GET v1/users/1
    def show
      json_response(@user, status: :ok)
    end

    # POST v1/users
    def create
      @user = User.create!(user_params)

      json_response(@user, status: :created, location: v1_user_url(@user))
    end

    # PATCH/PUT v1/users/1
    def update
      json_response(@user, status: :ok) if @user.update!(user_params)
    end

    # DELETE v1/users/1
    def destroy
      @user.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def user_params
        params.require(:user).permit(STRONG_PARAMETERS)
      end
  end
end