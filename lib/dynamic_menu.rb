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

    def current_page?(target, method)
      return false if target == nil or method == nil
      url_string = CGI.escapeHTML(target)
      request = controller.request
      if url_string =~ /^\w+:\/\//
        url_string == "#{request.protocol}#{request.host_with_port}#{request.request_uri}" and method.to_s == request.request_method.to_s
      else
        url_string == request.request_uri and method.to_s == request.request_method.to_s
      end
    end

    def parents; ([] << self[:parent] << (self[:parent] ? self[:parent].parents : nil)).flatten.compact; end

    def self_with_parents; [self, self.parents].flatten.compact; end

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
      @targets            = options.delete(:targets)      || [args[2]].flatten
      @active             = options.delete(:active)
      
      @auto_active        = (_controller and (options.delete(:auto_active) || true)) or nil
      @html_options       = {}

      options.each { |key, value| self[key.to_sym] = value }

      yield(self) if block_given?

      @active = @active || [[@target] + @targets].flatten.compact.map { |target|
                    if target.is_a?(String)
                      url     = target
                      method  = :get
                    elsif target.is_a?(Hash)
                      url     = target[:url]
                      method  = target[:method] || :get
                    end
                    current_page?(url, method)
                  }.include?(true)

      if @active
        self[:html_options][:class].blank? ? (self[:html_options][:class] = (@active_class || 'active')) : (self[:html_options][:class] += ' ' + (@active_class || 'active'))
      end

    end

  end

  def dynamic_menu(*args, &block)
    DynamicMenu.new(self, *args, &block)
  end
end
