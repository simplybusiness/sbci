require "fileutils"
require "rest_client"
require "grit"
require "uri"
require "rubygems"
require "sbci/version"
require "yaml"

module SBCI

  INITIAL_CONFIG_PATH = "#{File.expand_path("../..",__FILE__)}/lib/config.xml"
  MESSAGES = {
    :config_dir_exists => "Config already exists for this project",
    :config_already_exists => "Config file already exists and will be overwritten",
    :config_already_published => "Config file is already published and will be overwritten"
  }

  def self.pwd
    @pwd = Dir.pwd
  end

  class Job

    def self.repo_name
      conf = Grit::Config.new(get_repo)
      conf["remote.origin.url"].gsub(/\.git$/,"").split("/").last
    end

    def self.branch_name
      Grit::Head.current(get_repo).name
    end

    def self.get_repo
      Grit::Repo.new(".")
    end

    ATTRIBUTES = [
      :host, :port, :branch_name, :job_name, :path, :force
    ].freeze

    DEFAULTS = {
      :host => "localhost",
      :port => 8080,
      :path => "",
      :job_name => self.repo_name,
      :force => false
    }

    ATTRIBUTES.each do |attr|
      attr_accessor attr
    end

    def initialize(args = nil)
      args.delete_if{ |k,v| v.nil? || v == ""} if args.is_a?(Hash)
      args = args ? DEFAULTS.merge(args) : DEFAULTS

      ATTRIBUTES.each do |attr|
        if (args.key?(attr))
          instance_variable_set("@#{attr}", args[attr])
        end
      end
    end

    def create
      prompt(SBCI::MESSAGES[:config_already_exists], config_exists?) do
        FileUtils.cp(SBCI::INITIAL_CONFIG_PATH, config_file_path)
      end
    end

    def publish
      already_published = published?
      url = if already_published
        "#{host_with_port}/job/#{job_name}/config.xml"
      else
        "#{host_with_port}/createItem?name=#{job_name}"
      end
      prompt(SBCI::MESSAGES[:config_already_published], already_published) do
        RestClient.post(URI.escape(url), File.read(config_file_path), :content_type => :xml)
      end
    end

    def published?
      begin
        RestClient.get(URI.escape("#{host_with_port}/job/#{self.job_name}/config.xml"))
      rescue
        false
      else
        true
      end
    end

    def dump
      prompt(SBCI::MESSAGES[:config_already_exists], config_exists?) do
        response = RestClient.get(URI.escape("#{host_with_port}/job/#{self.job_name}/config.xml"))
        File.open(config_file_path, "w") {|f| f.write(response.body) }
        response
      end
    end

    def delete
      begin
        RestClient.post(URI.escape("#{host_with_port}/job/#{self.job_name}/doDelete"), {})
      rescue RestClient::Found
        true
      end
    end

    def config_file_path
      File.join(config_file_dir, "#{self.job_name}.xml")
    end

    def config_file_dir
      file_dir = File.join(SBCI.pwd, self.path)
      FileUtils.mkdir_p(file_dir)
      file_dir
    end

    def config_exists?
      File.exists?(config_file_path)
    end

    def host_with_port
      "#{host}:#{port}"
    end

    def delete_config
      FileUtils.rm(config_file_path) if File.exists?(config_file_path)
    end

    private

    def prompt(message, condition = true, &block)
      if !self.force && condition
        message << "\nDo you want to continue [Y/n] ? "
        print(message)
        answer = gets
        yield if answer.strip.downcase == "y"
      else
        yield
      end
    end

  end

end
