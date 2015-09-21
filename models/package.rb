class Package < ActiveRecord::Base
  has_many :user_packages
  has_many :users, through: :user_packages
  def create
    super
  end
end
