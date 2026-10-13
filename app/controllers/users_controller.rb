class UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record
  before_action :authenticate_user! , except: %i[create login]
  before_action :require_admin! , only: :admin_dashboard
  def create
     user = CreateUser.call(user_params)
  
     render json: { status: "User created successfully", 
                     user: {
                             id: user.id,
                             name: user.name,
                             email: user.email
                           }
                   }, 
                   status: :created
  end

  def login
    user = User.find_by(email: params[:user][:email])
   
    if user&.authenticate(params[:user][:password])
      token = JsonWebToken.encode({user_id: user.id})
      render json: {
        status: "Logged in successfully",
        user: {
          id: user.id,
          name: user.name,
          email: user.email
        },
        token: token
      }, status: :ok
    else
       render json: {
        status: "Invalid email/password "
    } , status: :unauthorized
      end
  end  

  def show
  
    user = User.find(params[:id])

    unless UserPolicy.new(current_user, user).show?
      render json: { message: "you are not authorized to access other user profile"}, status: :forbidden and return
    end

    render json: {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    tasks: user.tasks
                  }

  end  

  def admin_dashboard
  render json: {
    message: "Welcome to the admin dashboard",
    user: {
      id: current_user.id,
      name: current_user.name,
      role: current_user.role
    }
  }
end

  def tasks

    user = User.find(params[:user_id])

    unless UserPolicy.new(current_user, user).show?
      render json: { message: "you are not authorized to access other user data"}, status: :forbidden and return
    end
      
    completed = nil
    
    if params[:completed].present?  
       completed = ActiveRecord::Type::Boolean.new.cast(params[:completed])
    end    
    
    tasks = Rails.cache.fetch("users/#{user.id}/tasks", expires_in:5.minutes) do

       user.tasks.filter_by_completed(completed)
    
    end

    #Rails.cache.delete("total_records")

    total_records = Rails.cache.fetch("users/#{user.id}/tasks/total", expires_in:5.minutes) do
      tasks.count
    end
    
    #total_records = tasks.count


    if params[:order].present? 
       order = params[:order].downcase
       if order == 'asc'
         tasks = tasks.oldest_first
       elsif order == 'desc'
         tasks = tasks.newest_first
       end  
    end 

    page = params[:page].to_i
    page = 1 if page < 1
    limit = params[:limit].to_i
    limit = 10 if limit <= 0
    total_pages = (total_records.to_f/limit).ceil
    offset = ( page - 1 ) * limit   

    tasks = Rails.cache.fetch("users/#{user.id}/tasks/page/#{page}", expires_in: 5.minutes) do

      tasks.limit(limit).offset(offset)

    end
    
    has_next_page = page < total_pages
    has_previous_page = page > 1

    render json: {
      page: page,
      limit: limit,
      total_records: total_records,
      total_pages: total_pages,
      has_next_page: has_next_page,
      has_previous_page: has_previous_page,
      tasks: tasks.select(:id,:title,:completed)
       }
  end  

  private

  def record_not_found
    render json: {error: "Record not found"}, status: :not_found
  end  

  def user_params
    params.require(:user).permit(:name,:email,:password,:password_confirmation) 
  end

  def invalid_record(exception)
    render json: { error: exception.record.errors.full_messages }, status: :unprocessable_content
  end  
end