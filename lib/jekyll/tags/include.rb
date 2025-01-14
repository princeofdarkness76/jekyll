# encoding: UTF-8

module Jekyll
  module Tags
    class IncludeTagError < StandardError
      attr_accessor :path

      def initialize(msg, path)
        super(msg)
        @path = path
      end
    end

    class IncludeTag < Liquid::Tag
      attr_reader :includes_dir

      VALID_SYNTAX = /([\w-]+)\s*=\s*(?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w\.-]+))/
      VARIABLE_SYNTAX = /(?<variable>[^{]*(\{\{\s*[\w\-\.]+\s*(\|.*)?\}\}[^\s{}]*)+)(?<params>.*)/

      class << self
        def source_cache
          @@source_cache ||= {}
        end
      end

      class << self
        def source_cache
          @@source_cache ||= {}
        end
      end

<<<<<<< HEAD
=======
      class << self
        def source_cache
          @@source_cache ||= {}
        end
      end

      class << self
        def source_cache
          @@source_cache ||= {}
        end
      end

<<<<<<< HEAD
>>>>>>> pod/jekyll-glynn
=======
      class << self
        def source_cache
          @@source_cache ||= {}
        end
      end

>>>>>>> origin/cache-includes
      def initialize(tag_name, markup, tokens)
        super
        matched = markup.strip.match(VARIABLE_SYNTAX)
        if matched
          @file = matched['variable'].strip
          @params = matched['params'].strip
        else
          @file, @params = markup.strip.split(' ', 2)
        end
        validate_params if @params
        @tag_name = tag_name
      end

      def syntax_example
        "{% #{@tag_name} file.ext param='value' param2='value' %}"
      end

      def parse_params(context)
        params = {}
        markup = @params

        while match = VALID_SYNTAX.match(markup) do
          markup = markup[match.end(0)..-1]

          value = if match[2]
                    match[2].gsub(/\\"/, '"')
                  elsif match[3]
                    match[3].gsub(/\\'/, "'")
                  elsif match[4]
                    context[match[4]]
                  end

          params[match[1]] = value
        end
        params
      end

      def validate_file_name(file)
        if file !~ /^[a-zA-Z0-9_\/\.-]+$/ || file =~ /\.\// || file =~ /\/\./
          raise ArgumentError.new <<-eos
Invalid syntax for include tag. File contains invalid characters or sequences:

  #{file}

Valid syntax:

  #{syntax_example}

eos
        end
      end

      def validate_params
        full_valid_syntax = Regexp.compile('\A\s*(?:' + VALID_SYNTAX.to_s + '(?=\s|\z)\s*)*\z')
        unless @params =~ full_valid_syntax
          raise ArgumentError.new <<-eos
Invalid syntax for include tag:

  #{@params}

Valid syntax:

  #{syntax_example}

eos
        end
      end

      # Grab file read opts in the context
      def file_read_opts(context)
        context.registers[:site].file_read_opts
      end

      # Render the variable if required
      def render_variable(context)
        if @file.match(VARIABLE_SYNTAX)
          partial = context.registers[:site].liquid_renderer.file("(variable)").parse(@file)
          partial.render!(context)
        end
      end

<<<<<<< HEAD
      def tag_includes_dir(context)
        context.registers[:site].config['includes_dir'].freeze
      end
=======
      def render(context)
        dir = File.join(File.realpath(context.registers[:site].source), INCLUDES_DIR)
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> origin/v1-stable
=======
>>>>>>> origin/v1-stable
=======
>>>>>>> jekyll/v1-stable

      def render(context)
<<<<<<< HEAD
        site = context.registers[:site]
        @includes_dir = tag_includes_dir(context)
        dir = resolved_includes_dir(context)
=======
        dir = File.join(File.realpath(context.registers[:site].source), INCLUDES_DIR)
>>>>>>> jekyll/v1-stable

        file = render_variable(context) || @file
        validate_file_name(file)

        path = File.join(dir, file)
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> pod/jekyll-glynn
        validate_path(path, dir, site.safe)

        # Add include to dependency tree
        if context.registers[:page] && context.registers[:page].key?("path")
          site.regenerator.add_dependency(
            site.in_source_dir(context.registers[:page]["path"]),
            path
          )
        end
=======
        validate_path(path, dir, context.registers[:site].safe)
>>>>>>> jekyll/v1-stable
<<<<<<< HEAD
=======
=======
        validate_path(path, dir, context.registers[:site].safe)
>>>>>>> origin/v1-stable
=======
        validate_path(path, dir, context.registers[:site].safe)
>>>>>>> origin/v1-stable
>>>>>>> pod/jekyll-glynn
=======
        validate_path(path, dir, context.registers[:site].safe)
>>>>>>> jekyll/v1-stable

        begin
          partial = load_cached_partial(path, context)

          context.stack do
            context['include'] = parse_params(context) if @params
            partial.render!(context)
          end
        rescue => e
          raise IncludeTagError.new e.message, File.join(@includes_dir, @file)
        end
      end

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> pod/jekyll-glynn
      def load_cached_partial(path, context)
        context.registers[:cached_partials] ||= {}
        cached_partial = context.registers[:cached_partials]

        if cached_partial.key?(path)
          cached_partial[path]
        else
          cached_partial[path] = context.registers[:site].liquid_renderer.file(path).parse(read_file(path, context))
        end
      end

      def resolved_includes_dir(context)
        context.registers[:site].in_source_dir(@includes_dir)
      end

      def validate_path(path, dir, safe)
        if safe && !realpath_prefixed_with?(path, dir)
          raise IOError.new "The included file '#{path}' should exist and should not be a symlink"
        elsif !File.exist?(path)
          raise IOError.new "Included file '#{path_relative_to_source(dir, path)}' not found"
        end
=======
      def validate_path(path, dir, safe)
        if safe && !realpath_prefixed_with?(path, dir)
          raise IOError.new "The included file '#{path}' should exist and should not be a symlink"
        elsif !File.exist?(path)
          raise IOError.new "Included file '#{path}' not found"
        end
<<<<<<< HEAD
=======
=======
      def validate_path(path, dir, safe)
        if safe && !realpath_prefixed_with?(path, dir)
          raise IOError.new "The included file '#{path}' should exist and should not be a symlink"
        elsif !File.exist?(path)
          raise IOError.new "Included file '#{path}' not found"
        end
      end

      def realpath_prefixed_with?(path, dir)
        File.exist?(path) && File.realpath(path).start_with?(dir)
>>>>>>> origin/v1-stable
>>>>>>> pod/jekyll-glynn
      end

      def realpath_prefixed_with?(path, dir)
        File.exist?(path) && File.realpath(path).start_with?(dir)
>>>>>>> jekyll/v1-stable
      end

      def path_relative_to_source(dir, path)
        File.join(@includes_dir, path.sub(Regexp.new("^#{dir}"), ""))
=======
      def validate_path(path, dir, safe)
        if safe && !realpath_prefixed_with?(path, dir)
          raise IOError.new "The included file '#{path}' should exist and should not be a symlink"
        elsif !File.exist?(path)
          raise IOError.new "Included file '#{path}' not found"
        end
=======
      def validate_path(path, dir, safe)
        if safe && !realpath_prefixed_with?(path, dir)
          raise IOError.new "The included file '#{path}' should exist and should not be a symlink"
        elsif !File.exist?(path)
          raise IOError.new "Included file '#{path}' not found"
        end
      end

      def realpath_prefixed_with?(path, dir)
        File.exist?(path) && File.realpath(path).start_with?(dir)
>>>>>>> jekyll/v1-stable
      end

      def realpath_prefixed_with?(path, dir)
        File.exist?(path) && File.realpath(path).start_with?(dir)
>>>>>>> origin/v1-stable
      end

      def realpath_prefixed_with?(path, dir)
        File.exist?(path) && File.realpath(path).start_with?(dir)
      end

      # This method allows to modify the file content by inheriting from the class.
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> pod/jekyll-glynn
      def read_file(file, context)
        File.read(file, file_read_opts(context))
=======
      def source(file, context)
        self.class.source_cache[file] ||= File.read(file, file_read_opts(context))
>>>>>>> jekyll/cache-includes
=======
      def source(file, context)
        self.class.source_cache[file] ||= File.read(file, file_read_opts(context))
>>>>>>> origin/cache-includes
<<<<<<< HEAD
=======
=======
      def source(file, context)
        self.class.source_cache[file] ||= File.read(file, file_read_opts(context))
>>>>>>> jekyll/cache-includes
=======
      def source(file, context)
        self.class.source_cache[file] ||= File.read(file, file_read_opts(context))
>>>>>>> origin/cache-includes
>>>>>>> pod/jekyll-glynn
=======
      def source(file, context)
        self.class.source_cache[file] ||= File.read(file, file_read_opts(context))
>>>>>>> origin/cache-includes
      end
    end

    class IncludeRelativeTag < IncludeTag
      def tag_includes_dir(context)
        '.'.freeze
      end

      def page_path(context)
        context.registers[:page].nil? ? includes_dir : File.dirname(context.registers[:page]["path"])
      end

      def resolved_includes_dir(context)
        context.registers[:site].in_source_dir(page_path(context))
      end
    end
  end
end

Liquid::Template.register_tag('include', Jekyll::Tags::IncludeTag)
Liquid::Template.register_tag('include_relative', Jekyll::Tags::IncludeRelativeTag)
