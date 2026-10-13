class Task < ApplicationRecord
  belongs_to :user

  after_commit :invalidate_user_cache

  validates :title, presence: true
  validates :completed, inclusion: { in: [true , false]}
  
  scope :completed, -> { where(completed: true)}
  scope :pending, -> { where(completed: false)}
  scope :with_completed, ->(value) { where(completed: value) }
  scope :newest_first, -> { order(created_at: :desc)}
  scope :oldest_first, -> { order(created_at: :asc)} 

  def self.filter_by_completed(value)
    return all if value.nil?
    with_completed(value)
  end

  private

  def invalidate_user_cache
    Rails.cache.delete("users/#{user.id}/tasks/total")
  end 

end     