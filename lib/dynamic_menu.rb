require 'core_ext'
require 'menu_item'
require 'render_menu_helper'

class DynamicMenu < MenuItem

  def initialize(*args, &block)
    @items = []
    @parent = nil
    block.call(self) if block_given?
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

    block.call(self) if block_given?

  end

  def item_hash
    result = {}
    self.instance_variables.each do |i_v|
      result.merge!(i_v[1..-1].to_sym => self.instance_variable_get(i_v.to_sym))
    end
    result
  end

end
