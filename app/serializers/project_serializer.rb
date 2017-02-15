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

class ProjectSerializer < ActiveModel::Serializer
  include InplaceEditingHelper
  attributes :id, :name, :type, :image, :summary, :summary_html, :thumb_image, :sort_order, :slug

  def thumb_image
    self.object.thumb_image ? self.object.thumb_image_url : nil
  end

  def image
    self.object.thumb_image ? self.object.thumb_image_url : nil
  end

  def summary_html
    if self.object.summary
      markdown(self.object
        .summary)
    else
      nil
    end
  end
end
