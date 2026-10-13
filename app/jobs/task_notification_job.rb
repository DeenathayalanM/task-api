class TaskNotificationJob < ApplicationJob
  queue_as :default


   retry_on Net::OpenTimeout , wait: 5.seconds, attempts: 3

   def perform(task_id)
    task = Task.find_by(id: task_id)

    return unless task

    Rails.logger.info("Background job processed testing task: #{task.title}")
  end
end
