#/usr/bin/env ruby

class Hash
  def include?(other_hash)
    other_hash.each do |key, value|
      return false if self[key] != other_hash[key]
    end
    true
  end
end

class MenuItem

  def [](attribute)
    instance_variable_get("@#{attribute}".to_sym)
  end

  def []=(attribute, value)
    instance_variable_set("@#{attribute}".to_sym, value)
  end

  def items
    @items
  end

  def add(*args, &block)
    item = Item.new(*args, &block)
    item[:parent] = self
    @items << item
  end

  def remove(*args)
    @items.delete_if {|item| item.item_hash.include?(args.first) }
  end

  def clear
    @items.clear
  end

  def level
    i = 1
    s_p = self.parent
    while s_p = s_p.parent
      i += 1
    end
    i
  end

  def target
    parent and parent.target_completion ? (parent[:target] + "#{self[:target]}") : self[:target]
  end

end

class DynamicMenu < MenuItem

  def initialize(*args, &block)
    @items = []
    @parent = nil
    self.instance_eval(&block) if block
  end

end

class Item < MenuItem

  def initialize(*args, &block)

    @items  = []
    @parent = nil

    options = args.last.is_a?(Hash) ? args.pop : {}
    puts options.inspect

    @name         = options[:name] || args[0]
    @target_completion = options[:target_completion].to_s == "true" ? true : false
    @target       = options[:target] || args[1]
    @html_options = options.delete(:html_options) || {}

    options.each do |key, value|
      self.instance_variable_set("@#{key.to_s}".to_sym, value)
    end

    self.instance_eval(&block) if block

  end

  def item_hash
    result = {}
    self.instance_variables.each do |i_v|
      result.merge!(i_v[1..-1].to_sym => self.instance_variable_get(i_v.to_sym))
    end
    result
  end

end


a = DynamicMenu.new do

  add 'Home', '/'
  add 'About us', '/about_us', :target_completion => false do
    add 'Staff', '/about_us/stuff'
    add 'Experts', '/experts'
    add 'Contacts'
  end
  add 'Research area'
  add 'Projects'
  add 'Publications', '/publications', :target_completion => true do
    add 'Analyses', '/analyses'
    add 'Studies', '/studies'
    add 'Roundtable', '/roundtable'
    add 'Book Review', '/book_review'
  end

end

puts a.inspect
