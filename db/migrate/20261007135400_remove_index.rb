class RemoveIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :tasks, :user_id
  end
end    