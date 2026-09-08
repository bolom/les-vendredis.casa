module Admin
  class UsersController < BaseController
    before_action :require_technical_access

    def index
      @users = User.order(:email_address)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_users_path, notice: "Utilisateur « #{@user.email_address} » créé."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      if @user == Current.user && user_params.key?("technical_access") &&
          ActiveModel::Type::Boolean.new.cast(user_params["technical_access"]) != @user.technical_access
        redirect_to edit_admin_user_path(@user), alert: "Vous ne pouvez pas modifier votre propre accès à la zone technique."
      elsif @user.update(user_params)
        redirect_to admin_users_path, notice: "Utilisateur « #{@user.email_address} » mis à jour."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      user = User.find(params[:id])
      if user == Current.user
        redirect_to admin_users_path, alert: "Vous ne pouvez pas supprimer votre propre compte."
      elsif User.count == 1
        redirect_to admin_users_path, alert: "Impossible de supprimer le dernier compte administrateur."
      else
        user.destroy!
        redirect_to admin_users_path, notice: "Utilisateur « #{user.email_address} » supprimé."
      end
    end

    private

    def user_params
      permitted = params.require(:user).permit(:email_address, :password, :password_confirmation, :technical_access)
      permitted.delete(:password) if permitted[:password].blank?
      permitted.delete(:password_confirmation) if permitted[:password_confirmation].blank?
      permitted
    end
  end
end
