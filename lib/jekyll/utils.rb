require 'mime/types'

module Jekyll
  module Utils
    extend self
    autoload :Platforms, 'jekyll/utils/platforms'
    autoload :Ansi, "jekyll/utils/ansi"

    # Constants for use in #slugify
    SLUGIFY_MODES = %w(raw default pretty)
    SLUGIFY_RAW_REGEXP = Regexp.new('\\s+').freeze
    SLUGIFY_DEFAULT_REGEXP = Regexp.new('[^[:alnum:]]+').freeze
    SLUGIFY_PRETTY_REGEXP = Regexp.new("[^[:alnum:]._~!$&'()+,;=@]+").freeze

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> pod/jekyll-glynn
    def strip_heredoc(str)
      str.gsub(/^[ \t]{#{(str.scan(/^[ \t]*(?=\S)/).min || "").size}}/, "")
=======
=======
>>>>>>> origin/pull/cleanup-document__post_read
<<<<<<< HEAD
=======
=======
>>>>>>> origin/pull/cleanup-document__post_read
=======
>>>>>>> origin/pull/cleanup-document__post_read
>>>>>>> pod/jekyll-glynn
    # Takes a slug and turns it into a simple title.

    def titleize_slug(slug)
      slug.split("-").map! do |val|
        val.capitalize!
      end.join(" ")
<<<<<<< HEAD
<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> origin/pull/cleanup-document__post_read
=======
>>>>>>> origin/pull/cleanup-document__post_read
=======
>>>>>>> pod/jekyll-glynn
>>>>>>> origin/pull/cleanup-document__post_read
=======
>>>>>>> origin/pull/cleanup-document__post_read
    end

    # Non-destructive version of deep_merge_hashes! See that method.
    #
    # Returns the merged hashes.
    def deep_merge_hashes(master_hash, other_hash)
      deep_merge_hashes!(master_hash.dup, other_hash)
    end

    # Merges a master hash with another hash, recursively.
    #
    # master_hash - the "parent" hash whose values will be overridden
    # other_hash  - the other hash whose values will be persisted after the merge
    #
    # This code was lovingly stolen from some random gem:
    # http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
    #
    # Thanks to whoever made it.
    def deep_merge_hashes!(target, overwrite)
      overwrite.each_key do |key|
        if (overwrite[key].is_a?(Hash) || overwrite[key].is_a?(Drops::Drop)) &&
            (target[key].is_a?(Hash) || target[key].is_a?(Drops::Drop))
          target[key] = Utils.deep_merge_hashes(target[key], overwrite[key])
          next
        end

        target[key] = overwrite[key]
      end

      if target.respond_to?(:default_proc) && overwrite.respond_to?(:default_proc) && target.default_proc.nil?
        target.default_proc = overwrite.default_proc
      end

      target
    end

    # Read array from the supplied hash favouring the singular key
    # and then the plural key, and handling any nil entries.
    #
    # hash - the hash to read from
    # singular_key - the singular key
    # plural_key - the plural key
    #
    # Returns an array
    def pluralized_array_from_hash(hash, singular_key, plural_key)
      [].tap do |array|
        array << (value_from_singular_key(hash, singular_key) || value_from_plural_key(hash, plural_key))
      end.flatten.compact
    end

    def value_from_singular_key(hash, key)
      hash[key] if hash.key?(key) || (hash.default_proc && hash[key])
    end

    def value_from_plural_key(hash, key)
      if hash.key?(key) || (hash.default_proc && hash[key])
        val = hash[key]
        case val
        when String
          val.split
        when Array
          val.compact
        end
      end
    end

    def transform_keys(hash)
      result = {}
      hash.each_key do |key|
        result[yield(key)] = hash[key]
      end
      result
    end

    # Apply #to_sym to all keys in the hash
    #
    # hash - the hash to which to apply this transformation
    #
    # Returns a new hash with symbolized keys
    def symbolize_hash_keys(hash)
      transform_keys(hash) { |key| key.to_sym rescue key }
    end

    # Apply #to_s to all keys in the Hash
    #
    # hash - the hash to which to apply this transformation
    #
    # Returns a new hash with stringified keys
    def stringify_hash_keys(hash)
      transform_keys(hash) { |key| key.to_s rescue key }
    end

    # Parse a date/time and throw an error if invalid
    #
    # input - the date/time to parse
    # msg - (optional) the error message to show the user
    #
    # Returns the parsed date if successful, throws a FatalException
    # if not
    def parse_date(input, msg = "Input could not be parsed.")
      Time.parse(input).localtime
    rescue ArgumentError
      raise Errors::FatalException.new("Invalid date '#{input}': " + msg)
    end

    # Determines whether a given file has
    #
    # Returns true if the YAML front matter is present.
    def has_yaml_header?(file)
      !!(File.open(file, 'rb') { |f| f.readline } =~ /\A---\s*\r?\n/)
    rescue EOFError
      false
    end

    # Slugify a filename or title.
    #
    # string - the filename or title to slugify
    # mode - how string is slugified
    # cased - whether to replace all  uppercase letters with their
    # lowercase counterparts
    #
    # When mode is "none", return the given string.
    #
    # When mode is "raw", return the given string,
    # with every sequence of spaces characters replaced with a hyphen.
    #
    # When mode is "default" or nil, non-alphabetic characters are
    # replaced with a hyphen too.
    #
    # When mode is "pretty", some non-alphabetic characters (._~!$&'()+,;=@)
    # are not replaced with hyphen.
    #
    # If cased is true, all uppercase letters in the result string are
    # replaced with their lowercase counterparts.
    #
    # Examples:
    #   slugify("The _config.yml file")
    #   # => "the-config-yml-file"
    #
    #   slugify("The _config.yml file", "pretty")
    #   # => "the-_config.yml-file"
    #
    #   slugify("The _config.yml file", "pretty", true)
    #   # => "The-_config.yml file"
    #
    # Returns the slugified string.
    def slugify(string, mode: nil, cased: false)
      mode ||= 'default'
      return nil if string.nil?

      unless SLUGIFY_MODES.include?(mode)
        return cased ? string : string.downcase
      end

      # Replace each character sequence with a hyphen
      re =
        case mode
        when 'raw'
          SLUGIFY_RAW_REGEXP
        when 'default'
          SLUGIFY_DEFAULT_REGEXP
        when 'pretty'
          # "._~!$&'()+,;=@" is human readable (not URI-escaped) in URL
          # and is allowed in both extN and NTFS.
          SLUGIFY_PRETTY_REGEXP
        end
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD

      # Strip according to the mode
      slug = string.gsub(re, '-')

      # Remove leading/trailing hyphen
      slug.gsub!(/^\-|\-$/i, '')

=======

      # Strip according to the mode
      slug = string.gsub(re, '-')

      # Remove leading/trailing hyphen
      slug.gsub!(/^\-|\-$/i, '')

>>>>>>> jekyll/master
=======

      # Strip according to the mode
      slug = string.gsub(re, '-')

      # Remove leading/trailing hyphen
      slug.gsub!(/^\-|\-$/i, '')

>>>>>>> jekyll/master
=======

      # Strip according to the mode
      slug = string.gsub(re, '-')

      # Remove leading/trailing hyphen
      slug.gsub!(/^\-|\-$/i, '')

>>>>>>> jekyll/master
=======

      # Strip according to the mode
      slug = string.gsub(re, '-')

      # Remove leading/trailing hyphen
      slug.gsub!(/^\-|\-$/i, '')

>>>>>>> jekyll/master
=======

      # Strip according to the mode
      slug = string.gsub(re, '-')

      # Remove leading/trailing hyphen
      slug.gsub!(/^\-|\-$/i, '')

>>>>>>> jekyll/master
=======

      # Strip according to the mode
      slug = string.gsub(re, '-')

      # Remove leading/trailing hyphen
      slug.gsub!(/^\-|\-$/i, '')

>>>>>>> jekyll/master
=======

      # Strip according to the mode
      slug = string.gsub(re, '-')

      # Remove leading/trailing hyphen
      slug.gsub!(/^\-|\-$/i, '')

>>>>>>> jekyll/master
=======

      # Strip according to the mode
      slug = string.gsub(re, '-')

      # Remove leading/trailing hyphen
      slug.gsub!(/^\-|\-$/i, '')

>>>>>>> jekyll/master
      slug.downcase! unless cased
      slug
    end

    # Add an appropriate suffix to template so that it matches the specified
    # permalink style.
    #
    # template - permalink template without trailing slash or file extension
    # permalink_style - permalink style, either built-in or custom
    #
    # The returned permalink template will use the same ending style as
    # specified in permalink_style.  For example, if permalink_style contains a
    # trailing slash (or is :pretty, which indirectly has a trailing slash),
    # then so will the returned template.  If permalink_style has a trailing
    # ":output_ext" (or is :none, :date, or :ordinal) then so will the returned
    # template.  Otherwise, template will be returned without modification.
    #
    # Examples:
    #   add_permalink_suffix("/:basename", :pretty)
    #   # => "/:basename/"
    #
    #   add_permalink_suffix("/:basename", :date)
    #   # => "/:basename:output_ext"
    #
    #   add_permalink_suffix("/:basename", "/:year/:month/:title/")
    #   # => "/:basename/"
    #
    #   add_permalink_suffix("/:basename", "/:year/:month/:title")
    #   # => "/:basename"
    #
    # Returns the updated permalink template
    def add_permalink_suffix(template, permalink_style)
      case permalink_style
      when :pretty
        template << "/"
      when :date, :ordinal, :none
        template << ":output_ext"
      else
        template << "/" if permalink_style.to_s.end_with?("/")
        template << ":output_ext" if permalink_style.to_s.end_with?(":output_ext")
      end
      template
    end

    # Work the same way as Dir.glob but seperating the input into two parts
    # ('dir' + '/' + 'pattern') to make sure the first part('dir') does not act
    # as a pattern.
    #
    # For example, Dir.glob("path[/*") always returns an empty array,
    # because the method fails to find the closing pattern to '[' which is ']'
    #
    # Examples:
    #   safe_glob("path[", "*")
    #   # => ["path[/file1", "path[/file2"]
    #
    #   safe_glob("path", "*", File::FNM_DOTMATCH)
    #   # => ["path/.", "path/..", "path/file1"]
    #
    #   safe_glob("path", ["**", "*"])
    #   # => ["path[/file1", "path[/folder/file2"]
    #
    # dir      - the dir where glob will be executed under
    #           (the dir will be included to each result)
    # patterns - the patterns (or the pattern) which will be applied under the dir
    # flags    - the flags which will be applied to the pattern
    #
    # Returns matched pathes
    def safe_glob(dir, patterns, flags = 0)
      return [] unless Dir.exist?(dir)
      pattern = File.join(Array patterns)
      return [dir] if pattern.empty?
      Dir.chdir(dir) do
        Dir.glob(pattern, flags).map { |f| File.join(dir, f) }
      end
    end

  end
end
