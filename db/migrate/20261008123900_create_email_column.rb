class CreateEmailColumn < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :email, :string
  end

  def down
    remove_column :users, :email
  end  
end    