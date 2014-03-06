# == Schema Information
#
# Table name: ideas
#
#  id         :integer          not null, primary key
#  content    :text
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Idea < ActiveRecord::Base
  belongs_to :user


  #-----------------------------------------------------------------------------
  # Scope
  #-----------------------------------------------------------------------------

  default_scope -> { order("ideas.created_at DESC") }

end
