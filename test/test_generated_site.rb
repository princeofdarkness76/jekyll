require 'helper'

class TestGeneratedSite < JekyllUnitTest
  context "generated sites" do
    setup do
      clear_dest
      config = Jekyll::Configuration::DEFAULTS.merge({'source' => source_dir, 'destination' => dest_dir})

      @site = fixture_site(config)
      @site.process
      @index = File.read(dest_dir('index.html'))
    end

    should "ensure post count is as expected" do
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
      assert_equal 49, @site.posts.size
=======
<<<<<<< HEAD
      assert_equal 48, @site.posts.size
=======
      assert_equal 37, @site.posts.size
>>>>>>> jekyll/v1-stable
>>>>>>> pod/jekyll-gemfile
=======
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
      assert_equal 48, @site.posts.size
=======
      assert_equal 37, @site.posts.size
>>>>>>> jekyll/v1-stable
=======
      assert_equal 37, @site.posts.size
>>>>>>> origin/v1-stable
=======
      assert_equal 49, @site.posts.size
>>>>>>> jekyll/master
=======
      assert_equal 49, @site.posts.size
>>>>>>> jekyll/master
=======
      assert_equal 49, @site.posts.size
>>>>>>> jekyll/master
=======
      assert_equal 49, @site.posts.size
>>>>>>> jekyll/master
=======
      assert_equal 49, @site.posts.size
>>>>>>> jekyll/master
=======
      assert_equal 49, @site.posts.size
>>>>>>> jekyll/master
=======
      assert_equal 49, @site.posts.size
>>>>>>> jekyll/master
=======
      assert_equal 49, @site.posts.size
>>>>>>> jekyll/master
=======
      assert_equal 49, @site.posts.size
>>>>>>> jekyll/master
=======
      assert_equal 37, @site.posts.size
>>>>>>> origin/v1-stable
>>>>>>> pod/jekyll-glynn
=======
      assert_equal 37, @site.posts.size
>>>>>>> jekyll/v1-stable
    end

    should "insert site.posts into the index" do
      assert @index.include?("#{@site.posts.size} Posts")
    end

    should "render latest post's content" do
      assert @index.include?(@site.posts.last.content)
    end

    should "hide unpublished posts" do
      published = Dir[dest_dir('publish_test/2008/02/02/*.html')].map {|f| File.basename(f)}

      assert_equal 1, published.size
      assert_equal "published.html", published.first
    end

    should "hide unpublished page" do
      assert !File.exist?(dest_dir('/unpublished.html'))
    end

    should "not copy _posts directory" do
      assert !File.exist?(dest_dir('_posts'))
    end

    should "process other static files and generate correct permalinks" do
      assert File.exist?(dest_dir('/about/index.html')), "about/index.html should exist"
      assert File.exist?(dest_dir('/contacts.html')), "contacts.html should exist"
      assert File.exist?(dest_dir('/dynamic_file.php')), "dynamic_file.php should exist"
    end

    should "print a nice list of static files" do
      time_regexp = "\\d+:\\d+"
      expected_output = Regexp.new <<-OUTPUT
- /css/screen.css last edited at #{time_regexp} with extname .css
- /pgp.key last edited at #{time_regexp} with extname .key
- /products.yml last edited at #{time_regexp} with extname .yml
- /symlink-test/symlinked-dir/screen.css last edited at #{time_regexp} with extname .css
OUTPUT
      assert_match expected_output, File.read(dest_dir('static_files.html'))
    end
  end

  context "generating limited posts" do
    setup do
      clear_dest
      config = Jekyll::Configuration::DEFAULTS.merge({'source' => source_dir, 'destination' => dest_dir, 'limit_posts' => 5})
      @site = fixture_site(config)
      @site.process
      @index = File.read(dest_dir('index.html'))
    end

    should "generate only the specified number of posts" do
      assert_equal 5, @site.posts.size
    end

    should "ensure limit posts is 0 or more" do
      assert_raises ArgumentError do
        clear_dest
        config = Jekyll::Configuration::DEFAULTS.merge({'source' => source_dir, 'destination' => dest_dir, 'limit_posts' => -1})

        @site = fixture_site(config)
      end
    end

    should "acceptable limit post is 0" do
      clear_dest
      config = Jekyll::Configuration::DEFAULTS.merge({'source' => source_dir, 'destination' => dest_dir, 'limit_posts' => 0})

      assert Site.new(config), "Couldn't create a site with the given limit_posts."
    end
  end
end
