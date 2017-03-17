# == Schema Information
#
# Table name: project_owners
#
#  id         :integer          not null, primary key
#  person_id  :integer
#  project_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProjectOwner < ActiveRecord::Base
  belongs_to :person
  belongs_to :project

  validates_presence_of :person, :project
end
