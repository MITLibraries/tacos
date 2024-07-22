# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  uid        :string           not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:openid_connect]

  validates :uid, presence: true
  validates :email, presence: true

  # Creating a user from Omniauth first requires us to determine whether fake_auth is enabled. If so, we need to
  # traverse the response hash differently than with OIDC, as developer mode returns metadata in a different structure.
  # @param auth Hash The authentication response from Omniauth.
  def self.from_omniauth(auth)
    User.where(uid: auth.extra.raw_info.preferred_username).first_or_create do |user|
      user.email = auth.extra.raw_info.email
    end
  end
end
