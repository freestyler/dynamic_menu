module MenuHelper
  def render_menu(dynamic_menu, *args)
    raise 'No DynamicMenu or Item Object' unless dynamic_menu.instance_of?(ActionController::Base::DynamicMenu)
    options = args.last.is_a?(Hash) ? args.last : {}
    model = options[:model] || [:ul, :li]

    content_tag model.first do
      dynamic_menu.items.map do |menu_item|
        content_tag model.last, (link_to menu_item.name, menu_item.target) + (menu_item.items.empty? ? '' : render_menu(menu_item, *args)), menu_item[:html_options] if menu_item.enabled?
      end
    end
  end
end
