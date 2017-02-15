# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  identifier :string
#  name       :string
#  icon_klass :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :icon
end
