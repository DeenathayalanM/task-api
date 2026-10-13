class AddPasswordDigest < ActiveRecord::Migration[8.1]
  def change
    add_column :users , :password_digest, :string , null: false, default: "password123"
  end 
end