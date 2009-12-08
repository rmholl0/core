require 'package_submitter'
require 'fileutils'
require 'aip'
require 'libxml'
require 'pp'

describe PackageSubmitter do

  ZIP_SIP = "spec/test-sips/ateam.zip"
  TAR_SIP = "spec/test-sips/ateam.tar"
  ZIP_SIP_NODIR = "spec/test-sips/ateam-nodir.zip"
  TAR_SIP_NODIR = "spec/test-sips/ateam-nodir.tar"

  before(:each) do
    FileUtils.mkdir_p "/tmp/d2ws"
    ENV["DAITSS_WORKSPACE"] = "/tmp/d2ws"

    LibXML::XML.default_keep_blanks = false
  end

  after(:each) do
    FileUtils.rm_rf "/tmp/d2ws"
  end

  it "should raise error on create AIP from ZIP file if DAITSS_WORKSPACE is not set to a valid dir" do
    ENV["DAITSS_WORKSPACE"] = ""

    lambda { PackageSubmitter.submit_sip :zip, ZIP_SIP, "ateam", "0.0.0.0", "cccccccccccccccccccccccccccccccc" }.should raise_error
  end

  it "should raise error on create AIP from TAR file if DAITSS_WORKSPACE is not set to a valid dir" do
    ENV["DAITSS_WORKSPACE"] = ""

    lambda { PackageSubmitter.submit_sip :tar, TAR_SIP, "ateam", "0.0.0.0", "cccccccccccccccccccccccccccccccc" }.should raise_error
  end

  it "should generate a unique IEID for each AIP created" do
    PackageSubmitter.stub!(:unzip_sip).and_return true
    PackageSubmitter.stub!(:untar_sip).and_return true
    Aip.stub!(:make_from_sip).and_return true
    true.stub!(:add_md).and_return true

    ieid_1 = PackageSubmitter.submit_sip :zip, ZIP_SIP, "ateam", "0.0.0.0", "cccccccccccccccccccccccccccccccc" 
    ieid_2 = PackageSubmitter.submit_sip :tar, TAR_SIP, "ateam", "0.0.0.0", "cccccccccccccccccccccccccccccccc"

    ieid_1.should_not == ieid_2
  end

  it "should submit a package and add a submission event to the polydescriptor on submission of a tar-extracted SIP" do
    ieid = PackageSubmitter.submit_sip :tar, TAR_SIP_NODIR, "ateam", "0.0.0.0", "cccccccccccccccccccccccccccccccc"

    File.exists?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "aip-md", "digiprov-0.xml")).should == true

    File.directory?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "aip-md")).should == true
    File.directory?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "file-md")).should == true
    File.directory?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "files")).should == true

    File.exists?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "descriptor.xml")).should == true
    File.exists?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "files", "ateam.tiff")).should == true
    File.exists?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "files", "ateam.xml")).should == true
    
    doc = LibXML::XML::Document.file File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "aip-md", "digiprov-0.xml")
    (doc.find_first "/premis/event/eventType").content.should == "Submission"
    (doc.find_first "/premis/event/eventOutcomeInformation/eventOutcome").content.should == "success"
  end

  it "should submit a package and add a submission event to the polydescriptor on submission of a zip-extracted SIP" do
    ieid = PackageSubmitter.submit_sip :zip, ZIP_SIP_NODIR, "ateam", "0.0.0.0", "cccccccccccccccccccccccccccccccc"

    File.exists?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "aip-md", "digiprov-0.xml")).should == true

    File.directory?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "aip-md")).should == true
    File.directory?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "file-md")).should == true
    File.directory?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "files")).should == true

    File.exists?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "descriptor.xml")).should == true
    File.exists?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "files", "ateam.tiff")).should == true
    File.exists?(File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "files", "ateam.xml")).should == true

    doc = LibXML::XML::Document.file File.join(ENV["DAITSS_WORKSPACE"], "aip-#{ieid}", "aip-md", "digiprov-0.xml")
    (doc.find_first "/premis/event/eventType").content.should == "Submission"
    (doc.find_first "/premis/event/eventOutcomeInformation/eventOutcome").content.should == "success"
  end
end
