# == Schema Information
#
# Table name: company_indices
#
#  id                 :integer          not null, primary key
#  code               :string
#  reference_date     :date
#  name               :string
#  value              :float
#  description        :text
#  calculation_params :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  level              :integer
#

class CompanyIndex < ActiveRecord::Base
  serialize :calculation_params, Hash
end
