# == Schema Information
#
# Table name: project_categories
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProjectCategory < ActiveRecord::Base
  belongs_to :project
  belongs_to :category
  
  validates_presence_of :project, :category
end
