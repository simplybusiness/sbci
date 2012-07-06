$:.unshift File.expand_path(File.join(File.dirname(__FILE__),'..','lib'))
require 'bahia'
require 'net/http'
require 'vcr'
 
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { :record => :once }
end

RSpec.configure {|c| c.include Bahia }