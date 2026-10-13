class User < ApplicationRecord
  has_secure_password
  
  has_many :tasks
  enum :role, {  user: 'user', admin: 'admin' }
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true 
  scope :named , ->(name) { where(name: name)}
  
end 