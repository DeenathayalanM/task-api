class TaskPolicy
  def initialize(user, task)
    @user = user
    @task = task
  end

  def show?
    owns_or_admin?
  end

  def update?
    owns_or_admin?
  end

  def destroy?
    @user.admin?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if @user.admin?
        @scope.all
      else
        @scope.where(user_id: @user.id)
      end
    end
  end
  
  private

  def owns_or_admin?
    @user.admin? || @task.user_id == @user.id
  end

end