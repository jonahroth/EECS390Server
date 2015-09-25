class UserWallpaper < ActiveRecord::Base
  belongs_to :user
  belongs_to :wallpaper

  def create
    super
  end
end
