# == Schema Information
#
# Table name: projects
#
#  id         :integer          not null, primary key
#  name       :string
#  type       :string
#  image      :string
#  summary    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Project < ActiveRecord::Base
  has_many :project_owners
  has_many :owners, through: :project_owners, foreign_key: "project_id", class_name: "Person"

  mount_uploader :image, StandardImageUploader

  translates :summary
end
