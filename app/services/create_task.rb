class CreateTask 
  def self.call(task_params,current_user)
    Task.transaction do
      task = current_user.tasks.create!(task_params)
      task
    end  
  end
end   