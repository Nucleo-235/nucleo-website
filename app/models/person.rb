# == Schema Information
#
# Table name: people
#
#  id         :integer          not null, primary key
#  name       :string
#  type       :string
#  image      :string
#  summary    :string
#  bio        :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Person < ActiveRecord::Base
  has_many :project_owners
  has_many :project, through: :project_owners

  mount_uploader :image, StandardImageUploader

  translates :summary, :bio
end
