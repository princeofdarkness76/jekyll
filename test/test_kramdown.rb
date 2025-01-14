# encoding: UTF-8

require 'helper'

class TestKramdown < JekyllUnitTest
  context "kramdown" do
    setup do
      @config = {
        'markdown' => 'kramdown',
        'kramdown' => {
          'smart_quotes' => 'lsquo,rsquo,ldquo,rdquo',
          'entity_output' => 'as_char',
          'toc_levels' => '1..6',
          'auto_ids' => false,
          'footnote_nr' => 1,

          'syntax_highlighter_opts' => {
            'bold_every' => 8, 'css' => :class
          }
        }
      }

      @config = Jekyll.configuration(@config)
      @markdown = Converters::Markdown.new(
        @config
      )
    end

    should "run Kramdown" do
      assert_equal "<h1>Some Header</h1>", @markdown.convert('# Some Header #').strip
    end

    context "when asked to convert smart quotes" do
      should "convert" do
        assert_match %r!<p>(&#8220;|“)Pit(&#8217;|’)hy(&#8221;|”)<\/p>!, @markdown.convert(%{"Pit'hy"}).strip
      end

      should "support custom types" do
        override = {
          'kramdown' => {
            'smart_quotes' => 'lsaquo,rsaquo,laquo,raquo'
          }
        }

        markdown = Converters::Markdown.new(Utils.deep_merge_hashes(@config, override))
        assert_match %r!<p>(&#171;|«)Pit(&#8250;|›)hy(&#187;|»)<\/p>!, \
          markdown.convert(%{"Pit'hy"}).strip
      end
    end

    should "render fenced code blocks with syntax highlighting" do
      result = nokogiri_fragment(@markdown.convert(Utils.strip_heredoc <<-MARKDOWN))
        ~~~ruby
        puts "Hello World"
        ~~~
      MARKDOWN

      selector = "div.highlighter-rouge>pre.highlight>code"
      refute result.css(selector).empty?
    end

    context "when a custom highlighter is chosen" do
      should "use the chosen highlighter if it's available" do
        override = { "markdown" => "kramdown", "kramdown" => { "syntax_highlighter" => :coderay }}
        markdown = Converters::Markdown.new(Utils.deep_merge_hashes(@config, override))
        result = nokogiri_fragment(markdown.convert(Utils.strip_heredoc <<-MARKDOWN))
          ~~~ruby
          puts "Hello World"
          ~~~
        MARKDOWN

        selector = "div.highlighter-coderay>div.CodeRay>div.code>pre"
        refute result.css(selector).empty?
      end

      should "support legacy enable_coderay... for now" do
        override = {
          "markdown" => "kramdown",
          "kramdown" => {
            "syntax_highlighter" => nil,
                "enable_coderay" => true
            }
        }

        markdown = Converters::Markdown.new(Utils.deep_merge_hashes(@config, override))
        result = nokogiri_fragment(markdown.convert(Utils.strip_heredoc <<-MARKDOWN))
          ~~~ruby
          puts "Hello World"
          ~~~
        MARKDOWN

        selector = "div.highlighter-coderay>div.CodeRay>div.code>pre"
        refute result.css(selector).empty?
      end
    end

<<<<<<< HEAD
    should "move coderay to syntax_highlighter_opts" do
      original = Kramdown::Document.method(:new)
      markdown = Converters::Markdown.new(Utils.deep_merge_hashes(@config, {
        "markdown" => "kramdown",
        "kramdown" => {
          "syntax_highlighter" => "coderay",
          "coderay" => {
            "hello" => "world"
          }
        }
      }))

      expect(Kramdown::Document).to receive(:new) do |arg1, hash|
        assert_equal hash["syntax_highlighter_opts"]["hello"], "world"
        original.call(arg1, hash)
      end

      markdown.convert("hello world")
=======
    should "convert quotes to smart quotes" do
      markdown = MarkdownConverter.new(@config)
      assert_equal "<p>&#8220;Pit&#8217;hy&#8221;</p>", markdown.convert(%{"Pit'hy"}).strip

      override = { 'kramdown' => { 'smart_quotes' => 'lsaquo,rsaquo,laquo,raquo' } }
      markdown = MarkdownConverter.new(@config.deep_merge(override))
      assert_equal "<p>&#171;Pit&#8250;hy&#187;</p>", markdown.convert(%{"Pit'hy"}).strip
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> jekyll/0.12.1-release
=======
>>>>>>> origin/0.12.1-release
=======
>>>>>>> pod/jekyll-glynn
>>>>>>> jekyll/0.12.1-release
=======
>>>>>>> origin/0.12.1-release
=======
>>>>>>> jekyll/0.12.1-release
=======
<<<<<<< HEAD
=======
>>>>>>> jekyll/0.12.1-release
=======
>>>>>>> jekyll/0.12.1-release
=======
>>>>>>> pod/jekyll-glynn
>>>>>>> origin/0.12.1-release
=======
>>>>>>> jekyll/0.12.1-release
=======
>>>>>>> origin/0.12.1-release
    end
  end
end
