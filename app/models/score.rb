
# The file specifies the Score Class
#
#
# Author::
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Score and its associations
class Score < ActiveRecord::Base
  named_scope :current, :select => "scores.*", :from => "scores, (select MAX(id) as id, user_id from scores GROUP BY user_id) as s2 ", :conditions => "s2.id = scores.id"

  belongs_to :item
  belongs_to :user
  belongs_to :scoretype

  before_save Proc.new { |score| Reputation.update_rawscore(score) }

  #Method is called in sessons_contoller::successful_login It implements the rule of awarding user points if he logs in to the site within 7 days
  def self.score_login(user)
    newscoretype = Scoretype.find_by_name('login_score', :order => "version desc")
    login = user.last_login
    #if user has logged in this week, do not add log_score
    newscoretype.award = 0 if !login.nil? && (login.beginning_of_week() == Time.new.beginning_of_week())
    self.create_newscore(user, nil, newscoretype)
  end

  #Method is called in the ratingaction model. It implements the rules that decide the rules for which the vote is to be scored
  def self.score_vote(ratingaction)
    item = Item.find(ratingaction.item_id)
    user = User.find(ratingaction.user_id)
    newscoretype = Scoretype.find_by_name('vote_score', :order => "version desc")
    votes = user.scores.find_all_by_scoretype_id(newscoretype, :order => "created_at desc")
    today = Time.new.beginning_of_day()
    votes.each do |vote|
      #if user has voted today, do not add vote_score;
      newscoretype.award = 0; break if vote.created_at.beginning_of_day() == today
      #if user has already voted on this item, do not add vote_score;
      newscoretype.award = 0; break if vote.item == item;
    end
    self.create_newscore(user, item, newscoretype)
  end

  #Method is called in the ratingitemtotal model. It give scores to an item depeding upon hte ratinitemtotal
  def self.score_item(ratingitemtotal)
    item = ratingitemtotal.item
    user = ratingitemtotal.item.user
    return self.score_negative(user, item) if ratingitemtotal.rating_total < 0
    return self.score_positive(user, item) if ratingitemtotal.rating_total >= 0
    #if ratingitemtotal.rating_total == 0
    #  old_score = self.last_score_item(user,item)
    #  #remove old score award
    #  self.score_undo(old_score) unless old_score.nil?
    #end
  end

  #Method is called in the nuke method of the item model and is used to nuke an item
  def self.score_nuke(item)
    user = User.find(item.user_id)
    newscoretype = Scoretype.find_by_name('nuke_score', :order => "version desc")
    return self.create_newscore(user, item, newscoretype)
  end

  #Method is called in the nuke method of the item model and is used to un-nuke an item
  def self.score_unnuke(item)
    user = User.find(item.user_id)
    newscoretype = Scoretype.find_by_name('unnuke_score', :order => "version desc")
    return self.create_newscore(user, item, newscoretype)
  end

  #Method is called in the score_adjust method of the user model for administrator to adjust the score
  def self.score_adjustment(user,award, item = nil)
    newscoretype = Scoretype.find_by_name('adjust_score', :order => "version desc")
    newscoretype.award = award
    return self.create_newscore(user, item, newscoretype)
  end

  #Compare method
  def <=>(o)
    self.created_at <=> o.created_at
  end

  private

  #Method negates last pos/neg reputation scoring based on item score
  def self.score_undo(score)
    award = score.scoretype.award
    return self.score_adjustment(score.user, -award, score.item)
  end

  #Method negates last pos/neg reputation scoring based on item score
  def self.last_score_item(user,item)
    typeids = Array.new
    typeids << Scoretype.find_all_by_name('pos_score').collect{|x| x.id}
    typeids << Scoretype.find_all_by_name('neg_score').collect{|x| x.id}
    typeids.flatten!
    itemscores = user.scores.find(:all, :conditions => {:item_id => item.id, :scoretype_id => typeids}, :order => "created_at desc")
    return itemscores.first unless itemscores.empty?
  end


  #method to award a positive score by user to an item
  def self.score_positive(user, item)
    old_score = self.last_score_item(user,item)
    unless old_score.nil?
      #no need to update the db
      return if old_score.scoretype.name == 'pos_score'
      #remove old score award
      self.score_undo(old_score)
    end
    newscoretype = Scoretype.find_by_name('pos_score', :order => "version desc")
    return self.create_newscore(user, item, newscoretype)
  end

  #method to award a negative score by user to an item
  def self.score_negative(user, item)
    old_score = self.last_score_item(user,item)
    unless old_score.nil?
      #no need to update the db
      return if old_score.scoretype.name == 'neg_score'
      #remove old score award
      self.score_undo(old_score)
    end
    newscoretype = Scoretype.find_by_name('neg_score', :order => "version desc")
    return self.create_newscore(user, item, newscoretype)
  end

  # method to create a new score corresponding to an item by a user
  def self.create_newscore(user, item, newscoretype)
    item = Item.new if item.nil?
    total = user.rawscore + newscoretype.award
    score = self.create(:user_id => user.id,:item_id => item.id, :scoretype_id => newscoretype.id, :rawscore => total, :award => newscoretype.award, :updated_at => Time.new)
    return score
  end
end
