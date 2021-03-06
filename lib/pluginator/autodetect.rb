require "pluginator/errors"
require "pluginator/group"
require "pluginator/name_converter"

module Pluginator
  # Add autodetection capabilities to Group
  # @see Group
  class Autodetect < Group

    # Automatically load plugins for given group (and type)
    #
    # @param group [String] name of the plugins group
    # @option type [String] name of the plugin type
    def initialize(group, options = {})
      super(group)
      setup_autodetect(options[:type])
    end

    def type
      @plugins[@force_type] unless @force_type.nil?
    end

  private

    include NameConverter

    def setup_autodetect(type)
      force_type(type)
      load_files(find_files)
    end

    def force_type(type)
      @force_type = type
    end

    def find_files
      Gem.find_files(file_name_pattern(@group, @force_type))
    end

    def load_files(file_names)
      file_names.each do |file_name|
        path, name, type = split_file_name(file_name, @group)
        load_plugin path
        register_plugin(type, name2class(name))
      end
    end

    def load_plugin(path)
      gemspec = Gem::Specification.find_by_path(path)
      gemspec.activate if gemspec && !gemspec.activated?
      require path
    end

  end
end
