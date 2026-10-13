class AddCompositeIndex < ActiveRecord::Migration[8.1]
  def change
    add_index :tasks, [:user_id , :completed, :created_at]
  end
end

