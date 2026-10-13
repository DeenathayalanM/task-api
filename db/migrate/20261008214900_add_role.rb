class AddRole < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role , :string , null: false , default: 'user'
    up_only do
      execute "UPDATE users set role = 'user' where role is null"
    end  
  end  
end  