class Message < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :user, :counter_cache => :messages_count
  belongs_to :target, :polymorphic => true, :counter_cache => :comments_count

  validates :content, :presence => true,
                      :length   => { :maximum => 140 }

  scope :default_order,    order('created_at DESC')
  scope :public,           where(:is_private => false)
  scope :private,          where(:is_private => true)
  scope :read,             where(:is_read => true)
  scope :unread,           where(:is_read => false)
  scope :archived,         where(:is_archived => true)
  scope :unarchived,       where(:is_archived => false)
  scope :with_proposal,    where { proposal_id != nil }
  scope :without_proposal, where { proposal_id == nil }
  scope :micro_posts,      where(:target_id => nil)
  scope :on_users,         where(:target_type => 'User')
  scope :on_startups,      where(:target_type => 'Startup')

  def is_public?
    !is_private
  end

  def is_private?
    !!is_private
  end

  def method_missing(symbol, *args)
    case symbol
      when /^is_(un)?(.*)\?/
        eval "#{$1 ? '!' : '!!'}is_#{$2}"
      when /^mark_as_(un)?(.*)!/
        update_attribute :"is_#{$2}", ($1 ? false : true)
    else
      super
    end
  end
end
