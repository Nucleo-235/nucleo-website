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

  attr_accessor :selected_categories

  has_many :project_owners, dependent: :destroy
  has_many :owners, through: :project_owners, foreign_key: "project_id", class_name: "Person"

  has_many :project_categories, dependent: :destroy
  has_many :categories, through: :project_categories

  mount_uploader :image, StandardImageUploader
  mount_uploader :thumb_image, StandardImageUploader

  validates_presence_of :name, :thumb_image, :image, :sort_order

  after_save :check_category_ids

  translates :summary

  def selected_categories
    @selected_categories || []
  end

  def has_category(category)
    categories.find_by(id: category.id).present?
  end

  protected
    def check_category_ids
      if selected_categories && ! selected_categories.empty?
        selected_categories.each do |category_id|
          self.project_categories.find_or_create_by(category_id: category_id)
        end
      end
    end
end
