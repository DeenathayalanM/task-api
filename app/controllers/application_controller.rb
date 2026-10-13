class ApplicationController < ActionController::API
include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError , with: :unauthorized_error
  
  private
  def authenticate_user!
    token = request.headers["Authorization"]&.split(' ')&.last

    if token.blank? 
       render json: {error: "Missing token"} , status: :unauthorized
       return
    end

    begin
       payload = JsonWebToken.decode(token)
       user_id = payload[0]["user_id"]  
       @current_user = User.find(user_id)
    rescue JWT::DecodeError
      render json: { error: "Invalid token" }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: "User not found" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end  

  def require_admin!
  unless current_user.admin?
    render json: {
      error: "Admin access required"
    }, status: :forbidden

    return
  end
end

  def unauthorized_error
    render json: {
    error: "You are not authorized to perform this action"
  }, status: :forbidden
  end  

end
  