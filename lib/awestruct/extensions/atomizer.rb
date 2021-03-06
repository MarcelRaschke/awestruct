module Awestruct
  module Extensions
    class Atomizer

      def initialize(entries, output_path, opts={})
        @entries = entries
        @output_path = output_path
        @num_entries = opts[:num_entries] || 50
        @content_url = opts[:content_url]
        @feed_title = opts[:feed_title]
        if opts[:template] && Pathname.new(opts[:template]).relative?
          @template = Pathname.new(::Awestruct::Engine.instance.site.config.dir).join(opts[:template])
        else
          @template = File.join( File.dirname(__FILE__), 'template.atom.haml' )
        end
      end

      def execute(site)
        entries = @entries.is_a?(Array) ? @entries : site.send( @entries ) || []
        unless ( @num_entries == :all )
          entries = entries[0, @num_entries]
        end

        atom_pages = []

        entries.each do |entry|
          feed_entry = site.engine.load_page(entry.source_path, :relative_path => entry.relative_source_path, :html_entities => false)

          feed_entry.output_path = entry.output_path
          feed_entry.date = feed_entry.timestamp.nil? ? entry.date : feed_entry.timestamp

          atom_pages << feed_entry
        end

        site.engine.set_urls(atom_pages)

        page = site.engine.load_page( @template )
        page.date = page.timestamp unless page.timestamp.nil?
        page.output_path = @output_path
        page.entries = atom_pages
        page.title = @feed_title || site.title || site.base_url
        page.content_url = @content_url || site.base_url
        site.pages << page
      end

    end
  end
end
