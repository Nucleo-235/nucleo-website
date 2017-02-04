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

class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :type, :image, :summary
end
