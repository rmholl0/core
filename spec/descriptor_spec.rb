require 'spec_helper'
require 'set'

describe "aip descriptor" do
  
  before :each do
    aip = aip_instance_from_sip 'ateam'
    aip.ingest!
    aip.should_not be_snafu
    aip.should_not be_rejected
    @descriptor = aip.mono_descriptor_file
  end
  
  it "should compact the descriptor into a single file" do
    @descriptor.should exist_on_fs
  end

  it "should validate against its schema" do
    pending 'objects coming from description service have bad @xsi:type'
    @descriptor.should be_valid_xml
  end
  
  it "should pass PREMIS in METS best practice" do
    pending 'package level metadata requires a representation, structMap will reference the rep'
    @descriptor.should conform_to_pim_bp
  end
  
  it "should have two premis representations for the package" do
    @descriptor.should have_r0_representation
    @descriptor.should have_rC_representation
  end
  
  it "should have r0 without products of transformations" do
    pending 'not all transformation md is available'
    r_0_files(@descriptor).to_s.should == transformations(@descriptor).keys.to_set
  end

  it "should have rC with products of transformations replacing predecessors" do
    pending 'not all transformation md is available'
    r_c_files(@descriptor).to_s.should == transformations(@descriptor).values.to_set
  end
  
  # it "should have globally unique identifiers (across the FDA) for events agents and objects"
  # it "We need to add representations, next iteration"
  # 
  # describe "premis containers" do
  #   it "should reside in its own mets container"
  #   it "should be part of the premis namespace"
  # end
  #   
  # it "should only have top level validation events, checksum check and failure events only"
  # it "should only have external provenance events if it is found"
  # it "should only have representation retrieval if it is found"
  # it "should only have eventOutcomeDetail if there are anomalies to report"
  # it "should not have an action plan event"
  # 
end