# encoding: UTF-8
require 'csv'

module Jekyll
  class Site
    attr_reader   :source, :dest, :config
    attr_accessor :layouts, :pages, :static_files, :drafts,
                  :exclude, :include, :lsi, :highlighter, :permalink_style,
                  :time, :future, :unpublished, :safe, :plugins, :limit_posts,
                  :show_drafts, :keep_files, :baseurl, :data, :file_read_opts,
                  :gems, :plugin_manager

    attr_accessor :converters, :generators, :reader
    attr_reader   :regenerator, :liquid_renderer

    include Jekyll::Hooks

    # Public: Initialize a new Site.
    #
    # config - A Hash containing site configuration details.
    def initialize(config)
      @config = config.clone

      %w(safe lsi highlighter baseurl exclude include future unpublished
        show_drafts limit_posts keep_files gems).each do |opt|
        self.send("#{opt}=", config[opt])
      end

      # Source and destination may not be changed after the site has been created.
      @source              = File.expand_path(config['source']).freeze
      @dest                = File.expand_path(config['destination']).freeze

      @reader = Jekyll::Reader.new(self)

      # Initialize incremental regenerator
      @regenerator = Regenerator.new(self)

      @liquid_renderer = LiquidRenderer.new(self)

      self.plugin_manager = Jekyll::PluginManager.new(self)
      self.plugins        = plugin_manager.plugins_path

      self.file_read_opts = {}
      self.file_read_opts[:encoding] = config['encoding'] if config['encoding']

      self.permalink_style = config['permalink'].to_sym

      Jekyll.sites << self

      reset
      setup
    end

    # Public: Read, process, and write this Site to output.
    #
    # Returns nothing.
    def process
      reset
      read
      generate
      render
      cleanup
      write
      print_stats
    end

    def print_stats
      if @config['profile']
        puts @liquid_renderer.stats_table
      end
    end

    # Reset Site details.
    #
    # Returns nothing
    def reset
      self.time = (config['time'] ? Utils.parse_date(config['time'].to_s, "Invalid time in _config.yml.") : Time.now)
      self.layouts = {}
      self.pages = []
      self.static_files = []
      self.data = {}
      @collections = nil
      @regenerator.clear_cache
      @liquid_renderer.reset

      if limit_posts < 0
        raise ArgumentError, "limit_posts must be a non-negative number"
      end

      Jekyll::Hooks.trigger :site, :after_reset, self
    end

    # Load necessary libraries, plugins, converters, and generators.
    #
    # Returns nothing.
    def setup
      ensure_not_in_dest

      plugin_manager.conscientious_require

      self.converters = instantiate_subclasses(Jekyll::Converter)
      self.generators = instantiate_subclasses(Jekyll::Generator)
    end

    # Check that the destination dir isn't the source dir or a directory
    # parent to the source dir.
    def ensure_not_in_dest
      dest_pathname = Pathname.new(dest)
      Pathname.new(source).ascend do |path|
        if path == dest_pathname
          raise Errors::FatalException.new "Destination directory cannot be or contain the Source directory."
        end
      end
    end

    # The list of collections and their corresponding Jekyll::Collection instances.
    # If config['collections'] is set, a new instance is created for each item in the collection.
    # If config['collections'] is not set, a new hash is returned.
    #
    # Returns a Hash containing collection name-to-instance pairs.
    def collections
      @collections ||= Hash[collection_names.map { |coll| [coll, Jekyll::Collection.new(self, coll)] } ]
    end

    # The list of collection names.
    #
    # Returns an array of collection names from the configuration,
    #   or an empty array if the `collections` key is not set.
    def collection_names
      case config['collections']
      when Hash
        config['collections'].keys
      when Array
        config['collections']
      when nil
        []
      else
        raise ArgumentError, "Your `collections` key must be a hash or an array."
      end
    end

    # Read Site data from disk and load it into internal data structures.
    #
    # Returns nothing.
    def read
<<<<<<< HEAD
      reader.read
      limit_posts!
      Jekyll::Hooks.trigger :site, :post_read, self
=======
      self.read_layouts
      self.read_directories
      self.read_data(config['data_source'])
    end

    # Read all the files in <source>/<layouts> and create a new Layout object
    # with each one.
    #
    # Returns nothing.
    def read_layouts
      base = File.join(self.source, self.config['layouts'])
      return unless File.exists?(base)
      entries = []
      Dir.chdir(base) { entries = filter_entries(Dir['**/*.*']) }

      entries.each do |f|
        name = f.split(".")[0..-2].join(".")
        self.layouts[name] = Layout.new(self, base, f)
      end
    end

    # Recursively traverse directories to find posts, pages and static files
    # that will become part of the site according to the rules in
    # filter_entries.
    #
    # dir - The String relative path of the directory to read. Default: ''.
    #
    # Returns nothing.
    def read_directories(dir = '')
      base = File.join(self.source, dir)
      entries = Dir.chdir(base) { filter_entries(Dir.entries('.')) }

      self.read_posts(dir)
      self.read_drafts(dir) if self.show_drafts
      self.posts.sort!
      limit_posts! if limit_posts > 0 # limit the posts if :limit_posts option is set

      entries.each do |f|
        f_abs = File.join(base, f)
        if File.directory?(f_abs)
          f_rel = File.join(dir, f)
          read_directories(f_rel) unless self.dest.sub(/\/$/, '') == f_abs
        elsif has_yaml_header?(f_abs)
          pages << Page.new(self, self.source, dir, f)
        else
          static_files << StaticFile.new(self, self.source, dir, f)
        end
      end
    end

    # Read all the files in <source>/<dir>/_posts and create a new Post
    # object with each one.
    #
    # dir - The String relative path of the directory to read.
    #
    # Returns nothing.
    def read_posts(dir)
      posts = read_things(dir, '_posts', Post)

      posts.each do |post|
        if post.published && (self.future || post.date <= self.time)
          aggregate_post_info(post)
        end
      end
   end

    # Read all the files in <source>/<dir>/_drafts and create a new Post
    # object with each one.
    #
    # dir - The String relative path of the directory to read.
    #
    # Returns nothing.
    def read_drafts(dir)
      drafts = read_things(dir, '_drafts', Draft)

      drafts.each do |draft|
        aggregate_post_info(draft)
      end
    end

    def read_things(dir, magic_dir, klass)
      get_entries(dir, magic_dir).map do |entry|
        klass.new(self, self.source, dir, entry) if klass.valid?(entry)
      end.reject do |entry|
        entry.nil?
      end
    end

    # Read and parse all yaml files under <source>/<dir>
    #
    # Returns nothing
    def read_data(dir)
      base = File.join(self.source, dir)
      return unless File.directory?(base) && (!self.safe || !File.symlink?(base))

      entries = Dir.chdir(base) { Dir['*.{yaml,yml}'] }
      entries.delete_if { |e| File.directory?(File.join(base, e)) }

      entries.each do |entry|
        path = File.join(self.source, dir, entry)
        next if File.symlink?(path) && self.safe

        key = sanitize_filename(File.basename(entry, '.*'))
        self.data[key] = YAML.safe_load_file(path)
      end
>>>>>>> jekyll/v1-stable
    end

    # Run each of the Generators.
    #
    # Returns nothing.
    def generate
      generators.each do |generator|
        generator.generate(self)
      end
    end

    # Render the site to the destination.
    #
    # Returns nothing.
    def render
      relative_permalinks_are_deprecated

      payload = site_payload

      Jekyll::Hooks.trigger :site, :pre_render, self, payload

      collections.each do |_, collection|
        collection.docs.each do |document|
          if regenerator.regenerate?(document)
            document.output = Jekyll::Renderer.new(self, document, payload).run
            document.trigger_hooks(:post_render)
          end
        end
      end

      pages.flatten.each do |page|
        if regenerator.regenerate?(page)
          page.render(layouts, payload)
        end
      end

      Jekyll::Hooks.trigger :site, :post_render, self, payload
    rescue Errno::ENOENT
      # ignore missing layout dir
    end

    # Remove orphaned files and empty directories in destination.
    #
    # Returns nothing.
    def cleanup
      site_cleaner.cleanup!
    end

    # Write static files, pages, and posts.
    #
    # Returns nothing.
    def write
      each_site_file do |item|
        item.write(dest) if regenerator.regenerate?(item)
      end
      regenerator.write_metadata
      Jekyll::Hooks.trigger :site, :post_write, self
    end

    def posts
      collections['posts'] ||= Collection.new(self, 'posts')
    end

    # Construct a Hash of Posts indexed by the specified Post attribute.
    #
    # post_attr - The String name of the Post attribute.
    #
    # Examples
    #
    #   post_attr_hash('categories')
    #   # => { 'tech' => [<Post A>, <Post B>],
    #   #      'ruby' => [<Post B>] }
    #
    # Returns the Hash: { attr => posts } where
    #   attr  - One of the values for the requested attribute.
    #   posts - The Array of Posts with the given attr value.
    def post_attr_hash(post_attr)
      # Build a hash map based on the specified post attribute ( post attr =>
      # array of posts ) then sort each array in reverse order.
      hash = Hash.new { |h, key| h[key] = [] }
      posts.docs.each { |p| p.data[post_attr].each { |t| hash[t] << p } }
      hash.values.each { |posts| posts.sort!.reverse! }
      hash
    end

    def tags
      post_attr_hash('tags')
    end

    def categories
      post_attr_hash('categories')
    end

    # Prepare site data for site payload. The method maintains backward compatibility
    # if the key 'data' is already used in _config.yml.
    #
    # Returns the Hash to be hooked to site.data.
    def site_data
      config['data'] || data
    end

    # The Hash payload containing site-wide data.
    #
    # Returns the Hash: { "site" => data } where data is a Hash with keys:
    #   "time"       - The Time as specified in the configuration or the
    #                  current time if none was specified.
    #   "posts"      - The Array of Posts, sorted chronologically by post date
    #                  and then title.
    #   "pages"      - The Array of all Pages.
    #   "html_pages" - The Array of HTML Pages.
    #   "categories" - The Hash of category values and Posts.
    #                  See Site#post_attr_hash for type info.
    #   "tags"       - The Hash of tag values and Posts.
    #                  See Site#post_attr_hash for type info.
    def site_payload
      Drops::UnifiedPayloadDrop.new self
    end

    # Get the implementation class for the given Converter.
    # Returns the Converter instance implementing the given Converter.
    # klass - The Class of the Converter to fetch.

    def find_converter_instance(klass)
      converters.find { |klass_| klass_.instance_of?(klass) } || \
        raise("No Converters found for #{klass}")
    end

    # klass - class or module containing the subclasses.
    # Returns array of instances of subclasses of parameter.
    # Create array of instances of the subclasses of the class or module
    # passed in as argument.

    def instantiate_subclasses(klass)
      klass.descendants.select { |c| !safe || c.safe }.sort.map do |c|
        c.new(config)
      end
    end

    # Warns the user if permanent links are relative to the parent
    # directory. As this is a deprecated function of Jekyll.
    #
    # Returns
    def relative_permalinks_are_deprecated
      if config['relative_permalinks']
        Jekyll.logger.abort_with "Since v3.0, permalinks for pages" \
                                " in subfolders must be relative to the" \
                                " site source directory, not the parent" \
                                " directory. Check http://jekyllrb.com/docs/upgrading/"\
                                " for more info."
      end
    end

    # Get the to be written documents
    #
    # Returns an Array of Documents which should be written
    def docs_to_write
      documents.select(&:write?)
    end

    # Get all the documents
    #
    # Returns an Array of all Documents
    def documents
      collections.reduce(Set.new) do |docs, (_, collection)|
        docs + collection.docs + collection.files
      end.to_a
    end

    def each_site_file
      %w(pages static_files docs_to_write).each do |type|
        send(type).each do |item|
          yield item
        end
      end
    end

    # Returns the FrontmatterDefaults or creates a new FrontmatterDefaults
    # if it doesn't already exist.
    #
    # Returns The FrontmatterDefaults
    def frontmatter_defaults
      @frontmatter_defaults ||= FrontmatterDefaults.new(self)
    end

    # Whether to perform a full rebuild without incremental regeneration
    #
    # Returns a Boolean: true for a full rebuild, false for normal build
    def incremental?(override = {})
      override['incremental'] || config['incremental']
    end

    # Returns the publisher or creates a new publisher if it doesn't
    # already exist.
    #
    # Returns The Publisher
    def publisher
      @publisher ||= Publisher.new(self)
    end

    # Public: Prefix a given path with the source directory.
    #
    # paths - (optional) path elements to a file or directory within the
    #         source directory
    #
    # Returns a path which is prefixed with the source directory.
    def in_source_dir(*paths)
      paths.reduce(source) do |base, path|
        Jekyll.sanitized_path(base, path)
      end
    end

    # Public: Prefix a given path with the destination directory.
    #
    # paths - (optional) path elements to a file or directory within the
    #         destination directory
    #
    # Returns a path which is prefixed with the destination directory.
    def in_dest_dir(*paths)
      paths.reduce(dest) do |base, path|
        Jekyll.sanitized_path(base, path)
      end
    end

    private

    # Limits the current posts; removes the posts which exceed the limit_posts
    #
    # Returns nothing
    def limit_posts!
      if limit_posts > 0
        limit = posts.docs.length < limit_posts ? posts.docs.length : limit_posts
        self.posts.docs = posts.docs[-limit, limit]
      end
    end

    # Returns the Cleaner or creates a new Cleaner if it doesn't
    # already exist.
    #
    # Returns The Cleaner
    def site_cleaner
      @site_cleaner ||= Cleaner.new(self)
    end
  end
end
