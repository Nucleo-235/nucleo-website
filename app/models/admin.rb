# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  type                   :string
#  name                   :string
#

class Admin < User
  def self.create_admin_if_new(email, name)
    admin = Admin.find_by(email: email)
    if !admin
      admin = Admin.new(name: name, email: email, password: "12345678", password_confirmation: "12345678")
      # admin.skip_confirmation!
      admin.save!
    end
  end
  
end
