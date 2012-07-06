require 'fileutils'
require 'spec_helper'
require 'sbci'

describe SBCI::Job do

  before(:all) do
    @job_name = "test_job"
    @path = "spec/fixtures/jenkins"
    @sb = SBCI::Job.new(:path => @path, :job_name => @job_name)
  end

  before(:each) do
    @sb.delete_config
    VCR.use_cassette("delete") do
      @sb.delete
    end
  end

  context "Initializing" do

    it "should initialize with default parameters and git branch and repo" do
      sb = SBCI::Job.new
      sb.host.should == "localhost"
      sb.port.should == 8080
      sb.branch_name == "master"
      sb.job_name == "sbci_build"
      sb.force == false
    end

    it "should initialize with specified parameters" do
      sb = SBCI::Job.new(:host => "example.com", :port => 8000, :job_name => @job_name, :force => true)
      sb.host.should == "example.com"
      sb.port.should == 8000
      sb.job_name.should == @job_name
      sb.force == true
    end

  end

  context "Creating" do

    it "should create a configuration xml template file" do
      @sb.config_exists?.should be_false
      @sb.create
      @sb.config_exists?.should be_true
    end

    it "should force create a configuration xml template file without prompt" do
      @sb.config_exists?.should be_false
      @sb.create
      @sb.config_exists?.should be_true
      @sb.force = true
      @sb.create
      @sb.should_not_receive(:print)
      @sb.config_exists?.should be_true
    end

  end

  context "Publishing" do

    before(:each) do
      @sb.create
    end

    it "should publish a configuration xml to create a new Jenkins job" do
      VCR.use_cassette("publish") do
        @sb.published?.should be_false
        @sb.publish.code.should == 200
      end
    end

  end

  context "Re-publishing" do
  
    before(:each) do
      @sb.create
      VCR.use_cassette("publish") do
        @sb.publish
      end
    end
  
    it "should re-publish a configuration xml to update an existing Jenkins job" do
      VCR.use_cassette("republish") do
        @sb.published?.should be_true
        @sb.stub(:print)
        @sb.stub(:gets).and_return('y')
        @sb.publish.code.should == 200
      end
    end
  
    it "should force re-publish an existing Jenkins job without prompting" do
      VCR.use_cassette("republish") do
        @sb.published?.should be_true
        @sb.force = true
        @sb.should_not_receive(:print)
        @sb.publish.code.should == 200
      end
    end
  
  end
  
  context "Dumping" do
  
    before(:each) do
      @sb.create
      VCR.use_cassette("publish") do
        @sb.publish
      end
    end
  
    it "should dump a configuration xml from an existing project" do
      @sb.delete_config
      @sb.config_exists?.should be_false
      VCR.use_cassette("dump") do
        @sb.dump.code.should == 200
        @sb.config_exists?.should be_true
      end
    end
  
    it "should force dump a configuration xml over an existing one without prompt" do
      @sb.config_exists?.should be_true
      @sb.force = true
      @sb.should_not_receive(:print)
      VCR.use_cassette("dump") do
        @sb.dump.code.should == 200
      end
    end
  
  end
  
  context "Deleting" do
  
    before(:each) do
      @sb.create
    end
  
    it "should delete a job" do
      VCR.use_cassette("publish") do
        @sb.publish
      end
      VCR.use_cassette("delete") do
        @sb.delete.should be_true
      end
    end
  
  end

end
