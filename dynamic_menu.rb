#/usr/bin/env ruby

require 'core_ext'
require 'menu_item'

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

# puts a.inspect
