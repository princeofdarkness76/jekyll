module Jekyll
  module Commands
    class Serve < Command
      class << self
        COMMAND_OPTIONS = {
          "ssl_cert" => ["--ssl-cert [CERT]", "X.509 (SSL) certificate."],
          "host"     => ["host", "-H", "--host [HOST]", "Host to bind to"],
          "open_url" => ["-o", "--open-url", "Launch your browser with your site."],
          "detach"   => ["-B", "--detach", "Run the server in the background (detach)"],
          "ssl_key"  => ["--ssl-key [KEY]", "X.509 (SSL) Private Key."],
          "port"     => ["-P", "--port [PORT]", "Port to listen on"],
          "baseurl"  => ["-b", "--baseurl [URL]", "Base URL"],
          "skip_initial_build" => ["skip_initial_build", "--skip-initial-build",
            "Skips the initial site build which occurs before the server is started."]
        }

        #

        def init_with_program(prog)
          prog.command(:serve) do |cmd|
            cmd.description "Serve your site locally"
            cmd.syntax "serve [options]"
            cmd.alias :server
            cmd.alias :s

            add_build_options(cmd)
            COMMAND_OPTIONS.each do |key, val|
              cmd.option key, *val
            end

            cmd.action do |_, opts|
              opts["serving"] = true
              opts["watch"  ] = true unless opts.key?("watch")
              Build.process(opts)
              Serve.process(opts)
            end
          end
        end

        #

<<<<<<< HEAD
        def process(opts)
          opts = configuration_from_options(opts)
          destination = opts["destination"]
          setup(destination)
=======
          s = WEBrick::HTTPServer.new(webrick_options(options))
          s.unmount("")

          s.mount(
            options['baseurl'],
            custom_file_handler,
            destination,
            file_handler_options
          )

          Jekyll.logger.info "Server address:", server_address_info(s, options)
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> jekyll/change-default-listening-host
=======
>>>>>>> origin/change-default-listening-host
=======
<<<<<<< HEAD
>>>>>>> jekyll/change-default-listening-host
=======
>>>>>>> origin/change-default-listening-host
=======
>>>>>>> origin/change-default-listening-host
>>>>>>> pod/jekyll-glynn

          server = WEBrick::HTTPServer.new(webrick_opts(opts)).tap { |o| o.unmount("") }
          server.mount(opts["baseurl"], Servlet, destination, file_handler_opts)
          Jekyll.logger.info "Server address:", server_address(server, opts)
          launch_browser server, opts if opts["open_url"]
          boot_or_detach server, opts
        end

        # Do a base pre-setup of WEBRick so that everything is in place
        # when we get ready to party, checking for an setting up an error page
        # and making sure our destination exists.

        private
        def setup(destination)
          require_relative "serve/servlet"

          FileUtils.mkdir_p(destination)
          if File.exist?(File.join(destination, "404.html"))
            WEBrick::HTTPResponse.class_eval do
              def create_error_page
                @header["Content-Type"] = "text/html; charset=UTF-8"
                @body = IO.read(File.join(@config[:DocumentRoot], "404.html"))
              end
            end
          end
        end

        #

        private
        def webrick_opts(opts)
          opts = {
            :JekyllOptions      => opts,
            :DoNotReverseLookup => true,
            :MimeTypes          => mime_types,
            :DocumentRoot       => opts["destination"],
            :StartCallback      => start_callback(opts["detach"]),
            :BindAddress        => opts["host"],
            :Port               => opts["port"],
            :DirectoryIndex     => %W(
              index.htm
              index.html
              index.rhtml
              index.cgi
              index.xml
            )
          }

          enable_ssl(opts)
          enable_logging(opts)
          opts
        end

        # Recreate NondisclosureName under utf-8 circumstance

        private
        def file_handler_opts
          WEBrick::Config::FileHandler.merge({
            :FancyIndexing     => true,
            :NondisclosureName => [
              '.ht*', '~*'
            ]
          })
        end

        #

        private
        def server_address(server, opts)
          address = server.config[:BindAddress]
          baseurl = "#{opts["baseurl"]}/" if opts["baseurl"]
          port = server.config[:Port]

          "http://#{address}:#{port}#{baseurl}"
        end

        #

        private
        def launch_browser(server, opts)
          command =
            if Utils::Platforms.windows?
              "start"
            elsif Utils::Platforms.osx?
              "open"
            else
              "xdg-open"
            end
          system command, server_address(server, opts)
        end

        # Keep in our area with a thread or detach the server as requested
        # by the user.  This method determines what we do based on what you
        # ask us to do.

        private
        def boot_or_detach(server, opts)
          if opts["detach"]
            pid = Process.fork do
              server.start
            end

            Process.detach(pid)
            Jekyll.logger.info "Server detached with pid '#{pid}'.", \
              "Run `pkill -f jekyll' or `kill -9 #{pid}' to stop the server."
          else
            t = Thread.new { server.start }
            trap("INT") { server.shutdown }
            t.join
          end
        end

        # Make the stack verbose if the user requests it.

        private
        def enable_logging(opts)
          opts[:AccessLog] = []
          level = WEBrick::Log.const_get(opts[:JekyllOptions]["verbose"] ? :DEBUG : :WARN)
          opts[:Logger] = WEBrick::Log.new($stdout, level)
        end

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> pod/jekyll-glynn
        # Add SSL to the stack if the user triggers --enable-ssl and they
        # provide both types of certificates commonly needed.  Raise if they
        # forget to add one of the certificates.

        private
        def enable_ssl(opts)
          return if !opts[:JekyllOptions]["ssl_cert"] && !opts[:JekyllOptions]["ssl_key"]
          if !opts[:JekyllOptions]["ssl_cert"] || !opts[:JekyllOptions]["ssl_key"]
            raise RuntimeError, "--ssl-cert or --ssl-key missing."
=======
=======
>>>>>>> origin/add-support-for-webrick-file-precedence
<<<<<<< HEAD
=======
=======
>>>>>>> origin/add-support-for-webrick-file-precedence
=======
>>>>>>> origin/add-support-for-webrick-file-precedence
>>>>>>> pod/jekyll-glynn
        # Allows files to be routed in a pretty URL in both default format
        # and in custom page/index.html format and while doing so takes into
        # consideration importance of blog.html > blog/ but not > blog/index.html
        # because you could have URL's like blog.html, blog/archive/page.html
        # and in a normal circumstance blog/ would be greater than blog.html
        # breaking your entire site when you are playing around, and I
        # don't think you really want that to happen when testing do you?

        def custom_file_handler
          Class.new WEBrick::HTTPServlet::FileHandler do
            def search_file(req, res, basename)
              if (file = super) || (file = super req, res, "#{basename}.html")
                return file

              else
                file = File.join(@config[:DocumentRoot], req.path.gsub(/\/\Z/, "") + ".html")
                if File.expand_path(file).start_with?(@config[:DocumentRoot]) && File.file?(file)
                  return ".html"
                end
              end

              nil
            end
>>>>>>> jekyll/add-support-for-webrick-file-precedence
          end

          require "openssl"
          require "webrick/https"
          source_key = Jekyll.sanitized_path(opts[:JekyllOptions]["source"], opts[:JekyllOptions]["ssl_key" ])
          source_certificate = Jekyll.sanitized_path(opts[:JekyllOptions]["source"], opts[:JekyllOptions]["ssl_cert"])
          opts[:SSLCertificate] = OpenSSL::X509::Certificate.new(File.read(source_certificate))
          opts[:SSLPrivateKey ] = OpenSSL::PKey::RSA.new(File.read(source_key))
          opts[:EnableSSL] = true
        end

        private
        def start_callback(detached)
          unless detached
            proc do
              Jekyll.logger.info("Server running...", "press ctrl-c to stop.")
            end
          end
        end

        private
        def mime_types
<<<<<<< HEAD
          file = File.expand_path('../mime.types', File.dirname(__FILE__))
          WEBrick::HTTPUtils.load_mime_types(file)
=======
          mime_types_file = File.expand_path('../mime.types', File.dirname(__FILE__))
          WEBrick::HTTPUtils::load_mime_types(mime_types_file)
        end

        def server_address_info(server, options)
          bind_addr = server.config[:BindAddress].to_s
          listen_addr = bind_addr == "0.0.0.0" ? "localhost" : bind_addr
          base_url  = "#{options['baseurl']}/" if options['baseurl']

          rtn = "http://#{listen_addr}:#{server.config[:Port]}#{base_url}"
          rtn = "#{rtn} (listening on all interfaces)" if bind_addr == "0.0.0.0"
        rtn
        end

        # recreate NondisclosureName under utf-8 circumstance
        def file_handler_options
          WEBrick::Config::FileHandler.merge({
            :FancyIndexing     => true,
            :NondisclosureName => ['.ht*','~*']
          })
>>>>>>> jekyll/change-default-listening-host
        end
      end
    end
  end
end
