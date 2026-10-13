class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task , only: %i[show update destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid , with: :record_invalid
 
  def index
    tasks = policy_scope(Task).includes(:user)
    render json: tasks, include: :user
  end  

  def show 

    authorize @task

    render json: {
      task: @task,
      user: {
        id: @task.user.id,
        name: @task.user.name,
        email: @task.user.email,
        role: @task.user.role
    }
    }
  end  

  def create
     
    @task = CreateTask.call(task_params,current_user)
    if @task.persisted?
      render json: {status: "created successfully", task: @task } , status: :created
    else
      error_message
    end  
  end

  def update

    authorize @task
    
    if @task.update(task_params)
      render json: {status: "updated successfully", task: @task } , status: :ok
    else
      error_message
    end
  end  

  def destroy
   
  authorize @task

   @task.destroy
   render json: { status: "Deleted #{params[:id]} successfully" }, status: :ok
  
  end 

  private

  def task_policy
    TaskPolicy.new(current_user, @task)
  end

  def set_task
    
    @task = Task.includes(:user).find(params[:id])

  end  

  def task_params
    params.require(:task).permit(:title, :completed)
  end

  def record_not_found(exception)
    render json: {error: "Record not found"}, status: :not_found
  end

  def error_message
    render json: {error: @task.errors.full_messages}, status: :unprocessable_content
  end 
  
  def record_invalid(exception)
    render json: {
      errors: exception.record.errors.full_messages
    }, status: :unprocessable_content
  end

end