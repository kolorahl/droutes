module Droutes
  class Struct
    attr_reader :controller, :action, :verb, :path, :docs

    def initialize(controller, action, route, docs)
      @controller = controller
      @action = action
      @verb = route.verb
      @path = route.path
      @docs = docs
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
      files.collect do |file|
        parser = YARD::Parser::SourceParser.new.parse(file)
        handle(parser.enumerator)
      end
    end

    protected

    def handle(ast)
      ast.collect {|node| handle_class(node) if node.is_a?(YARD::Parser::Ruby::ClassNode)}.compact
    end

    def handle_node(ast)
      ast.collect do |node|
        if node.is_a?(YARD::Parser::Ruby::ClassNode)
          handle_class(node)
        elsif node.is_a?(YARD::Parser::Ruby::MethodDefinitionNode)
          handle_meth(node)
        elsif node.is_a?(YARD::Parser::Ruby::AstNode)
          handle_node(node)
        end
      end.compact
    end

    def handle_class(ast)
      @controller = ast.class_name.path.join("::").underscore
      @controller = @controller[0, @controller.length - "_controller".length]
      handle_node(ast)
    end

    def handle_meth(ast)
      action = ast.method_name(true).to_s
      route = @routes[@controller][action]
      return unless route
      Struct.new(@controller, action, route, YARD::Docstring.new(ast.docstring))
    end
  end
end
