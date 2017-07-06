  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end