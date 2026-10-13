class UserPolicy 
  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end
  
  def show?
    @current_user.admin? || @current_user.id == @user.id
  end  

end