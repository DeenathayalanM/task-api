class AddColumnTasks < ActiveRecord::Migration[8.1]
  def change
    change_table :tasks do |t|
      t.timestamps
    end
  end
end      