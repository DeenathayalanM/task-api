class AddColumnLockVersion < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :lock_version, :integer, default: 0

    up_only do
      execute "UPDATE tasks SET lock_version = 0 where lock_version is NULL"
    end

  end
end    