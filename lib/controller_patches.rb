require 'dispatcher'
Dispatcher.to_prepare do
    UserController.class_eval do
        require 'survey'
    end
end
