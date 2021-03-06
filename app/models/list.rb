class List < ActiveRecord::Base
  has_many :tags, dependent: :destroy
  has_many :items, dependent: :destroy
  belongs_to :user

  validates :name, :presence => true
  validates_uniqueness_of :name, :scope => :user_id
  attr_accessible :name

  # returns an array of tags sorted from most popular to least
  def sorted_tags
    get_tags.sort_by {|k,v| v}.reverse.unshift ["All items", self.items.count]
  end

  def items_with_tag(tag)
   self.items.select {|item| item.tags.map {|t| t.name}.include? tag }
  end

  def get_tags
    tags  = self.items.inject(Hash.new(0)) do |hash, item|
      item.tags.each do |tag|
        hash[tag.name] += 1
      end
      hash # so that the inject block returns the hash 
    end
  end
end
