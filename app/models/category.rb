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

class Category < ActiveRecord::Base
  translates :name

  def self.create_if_new(identifier, name, icon_klass = nil)
    item = Category.find_by(identifier: identifier)
    if !item
      icon_klass = identifier if !icon_klass
      item = Category.new(identifier: identifier, name: name, icon_klass: icon_klass)
      # admin.skip_confirmation!
      item.save!
    end
    item
  end
end
