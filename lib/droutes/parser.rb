module Droutes
  class ClassStruct
    attr_reader :name, :controller, :actions, :children, :docs

    def initialize(class_name, docs="")
      @name = class_name
      if class_name
        controller = class_name.underscore
        @controller = controller[0, controller.length - "_controller".length]
      end
      @actions = {}
      @children = []
      @docs = docs || ""
    end

    def set_action(action, data)
      @actions[action] = data
    end
  end

  class Struct
    attr_reader :klass, :action, :verb, :path, :docs

    def initialize(klass, action, route, docs)
      @klass = klass
      @action = action
      @verb = route.verb
      @path = route.path
      @docs = docs
    end

    def controller
      @klass.controller
    end
  end

  class Parser
    attr_reader :routes

    def initialize(routes)
      @routes = ::Hash.new {|h,k| h[k] = {}}
      routes.each do |route|
        wrap = ActionDispatch::Routing::RouteWrapper.new(route)
        next if wrap.internal?
        @routes[wrap.controller][wrap.action] = wrap
      end
    end

    def parse
      files = Dir["#{Rails.application.root}/app/controllers/**/*.rb"]
      root = ClassStruct.new(nil)
      files.each do |file|
        parser = YARD::Parser::SourceParser.new.parse(file)
        handle(parser.enumerator, root)
      end
      root
    end

    protected

    def handle(ast, klass)
      ast.each {|node| handle_class(node, klass) if node.is_a?(YARD::Parser::Ruby::ClassNode)}
    end

    def handle_node(ast, klass)
      ast.each do |node|
        if node.is_a?(YARD::Parser::Ruby::ClassNode)
          handle_class(node, klass)
        elsif node.is_a?(YARD::Parser::Ruby::MethodDefinitionNode)
          handle_def(node, klass)
        elsif node.is_a?(YARD::Parser::Ruby::AstNode)
          handle_node(node, klass)
        end
      end
    end

    def handle_class(ast, klass)
      class_name = ast.class_name.path.join("::")
      newKlass = ClassStruct.new(class_name, ast.docstring)
      klass.children.append(newKlass) if klass
    end

    def handle_def(ast, klass)
      action = ast.method_name(true).to_s
      route = @routes[klass.controller][action]
      return unless route
      klass.set_action(action, Struct.new(klass,
                                          action,
                                          route,
                                          YARD::Docstring.new(ast.docstring)))
    end
  end
end
