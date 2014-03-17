class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :creator, class_name: User

  validates :content, presence: true
  validates :creator, presence: true
  validates :commentable, presence: true
end
