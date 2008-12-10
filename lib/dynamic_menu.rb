module DynamicMenu

  class MenuItem
    attr_reader :name
    attr_reader :items
    attr_reader :target
    attr_reader :auto_active

    def [](attribute); instance_variable_get("@#{attribute}".to_sym); end
    def []=(attribute, value); instance_variable_set("@#{attribute}".to_sym, value); end
    
    def self_or_inherited_attribute(attribute)
      attribute = attribute.to_sym
      self[attribute] or (self[:parent] and self[:parent].self_or_inherited_attribute(attribute)) or nil
    end

    def add(*args, &block)
      item = DynamicMenu.new(self, *args, &block)
      @items.push item
    end

    def level
      i = 1
      s_p = self.parent
      while s_p = s_p.parent
        i += 1
      end
      i
    end

    def enabled?; @enabled; end
    def active?; @active; end
    def active_item; self.items.find { |item| item.active? }; end
    def position; self[:parent].items.index(self); end

    def next
      return nil if self[:parent].items.last == self
      self[:parent].items.at(self.position + 1)
    end

    def previous
      return nil if self[:parent].items.first == self
      self[:parent].items.at(self.position - 1)
    end

    alias :prev :previous

    protected

    def controller
      self_or_inherited_attribute(:controller)
    end

    def current_page?
      return false if self.target == nil
      url_string = CGI.escapeHTML(self.target)
      request = controller.request
      if url_string =~ /^\w+:\/\//
        url_string == "#{request.protocol}#{request.host_with_port}#{request.request_uri}"
      else
        url_string == request.request_uri
      end
    end

    def get_property(property)
      result_ary  = []
      temp_ary    = []
      if property.is_a?(Hash)
        result_ary << property_helper(property)
      elsif property.is_a?(Array)
        property.each do |property_item|
          if property_item.is_a?(Hash)
            result_ary << property_helper(property_item)
          end
        end
      end
      result_ary.include?(true)
    end

    def parents; ([] << self[:parent] << (self[:parent] ? self[:parent].parents : nil)).flatten.compact; end

    def self_with_parents; [self, self.parents].flatten.compact; end

    private

    def property_helper(property)
      raise 'No hash argument' unless property.is_a?(Hash)
      temp_ary = []
      property.each do |key, value|
        temp_ary << if value.is_a?(Array)
                      value.map {|v| self.self_with_parents.map { |item| item[key.to_sym].to_s == v.to_s } }.flatten.compact.include?(true)
        else
          self.self_with_parents.map { |item| item[key.to_sym].to_s == value.to_s }.include?(true)
        end
      end
      !temp_ary.include?(false)
    end

  end

  class DynamicMenu < MenuItem

    def initialize(*args, &block)

      _parent     = args[0].is_a?(DynamicMenu) ? args.delete_at(0) : nil
      _controller = args[0].is_a?(ActionController::Base) ? args.delete_at(0) : nil

      options = args.last.is_a?(Hash) ? args.pop : {}

      @parent             = _parent
      @controller         = _controller
      @items              = []
      @name               = options.delete(:name)         || args[0]
      @target             = options.delete(:target)       || args[1]
      @auto_active        = (_controller and (options.delete(:auto_active) || true)) or nil
      @html_options       = {}

      @enabled            = if enabled = options.delete(:enabled)
                              enabled if enabled.is_a?(TrueClass) or enabled.is_a?(FalseClass)
                              get_property(enabled) if enabled.is_a?(Hash) or enabled.is_a?(Array)
                            else
                              true
                            end

      @active            =  if active = options.delete(:active)
                              active if active.is_a?(TrueClass) or active.is_a?(FalseClass)
                              get_property(active) if active.is_a?(Hash) or active.is_a?(Array)
                            else
                              false
                            end

      @active            = true if not active and parents.collect(&:auto_active).compact.include?(true) and current_page?

      options.each { |key, value| self[key.to_sym] = value }

      if @active
        self[:html_options][:class].blank? ? (self[:html_options][:class] = (@active_class || 'active')) : (self[:html_options][:class] += ' ' + (@active_class || 'active'))
      end
      yield(self) if block_given?
    end

  end

  def dynamic_menu(*args, &block)
    DynamicMenu.new(self, *args, &block)
  end
end
