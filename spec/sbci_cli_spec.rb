require 'fileutils'
require 'spec_helper'
require 'sbci'

describe "sbci cli" do

  before(:all) do
    @options = { :job_name => "test_job",
                 :path => "spec/fixtures/jenkins",
                 :host => "localhost",
                 :port => 8080,
                 :force => true }
  end
  
  it "should pass the correct parameters" do
    sbci "debug #{@options.map{ |k,v| "--#{k.to_s.gsub('_','-')} #{v}" }.join(' ')}"
    stdout.should == YAML::dump(SBCI::Job.new(@options))
    stderr.should be_empty
  end

end
