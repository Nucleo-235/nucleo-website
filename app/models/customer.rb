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

class Customer < Person
  def self.create_if_new(name, summary, bio, image = nil)
    item = Customer.find_by(name: name)
    if !item
      item = Customer.new(name: name, image: image, summary: summary, bio: bio)
      # admin.skip_confirmation!
      item.save!
    end
    item
  end
end
