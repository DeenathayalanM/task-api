require 'rails_helper'
RSpec.describe Task , type: :model do
  it 'title should be present' do
      task = Task.new(title: "", completed: false, user_id: 1)
      expect(task).not_to be_valid
  end

   it 'user should be present' do
      task = Task.new(title: "test", completed: false)
      expect(task).not_to be_valid
  end

   it 'completed should be true/false' do
      User.create!(name: 'Deena', email: 'deena@gmail.com')
      task = Task.new(title: "test", completed: 'test', user_id: 1)
      expect(task.completed).to be true
   end

end 