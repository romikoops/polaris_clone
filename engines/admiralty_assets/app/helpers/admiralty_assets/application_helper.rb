# frozen_string_literal: true

module AdmiraltyAssets
  module ApplicationHelper
    def controller_classes
      namespace = controller_path.split('/')[0]
      [namespace, controller_class, controller_action_class].join(' ')
    end

    def controller_class
      controller_path.tr('/', '_')
    end

    def controller_action_class
      "#{controller_class}_#{controller.action_name}"
    end
  end
end
