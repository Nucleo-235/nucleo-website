# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  name        :string
#  type        :string
#  image       :string
#  summary     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  thumb_image :string
#  sort_order  :integer
#  slug        :string
#

class Project < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders]

  has_many :project_owners
  has_many :owners, through: :project_owners, foreign_key: "project_id", class_name: "Person"

  has_many :project_categories
  has_many :categories, through: :project_categories

  mount_uploader :image, StandardImageUploader
  mount_uploader :thumb_image, StandardImageUploader

  translates :summary
end
