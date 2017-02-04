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

class PersonSerializer < ActiveModel::Serializer
  attributes :id, :name, :type, :image, :summary, :bio
end
