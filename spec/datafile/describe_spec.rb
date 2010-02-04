require 'spec_helper'
require 'xmlns'
require 'datafile/describe'

describe 'describing a datafile' do

  subject do
    wip = submit_sip 'mimi'
    wip.datafiles.find { |df| df['sip-path'] =~ %r{\.pdf$} }
  end

  describe "premis metadata" do
    before(:all) { subject.describe! }
    it { should have_key('describe-event') }
    it { should have_key('describe-agent') }
    it { should have_key('describe-file-object') }
    it { should have_key('describe-bitstream-objects') }

    it "should have the datafile's uri as the of the premis file object" do
      doc = XML::Document.string subject['describe-file-object']
      file_object = doc.find_first "/P:object[@xsi:type = 'file']", NS_PREFIX
      file_object.should_not be_nil

      obj_id_type = file_object.find_first "P:objectIdentifier/P:objectIdentifierType", NS_PREFIX
      obj_id_type.should_not be_nil
      obj_id_type.content.should == 'URI'

      obj_id_value = file_object.find_first "P:objectIdentifier/P:objectIdentifierValue", NS_PREFIX
      obj_id_value.should_not be_nil
      obj_id_value.content.should == subject.uri
    end

    it "should have the datafile's uri as the base for any bitstreams" do
      doc = XML::Document.string subject['describe-bitstream-objects']
      bs_objects = doc.find "/P:object[@xsi:type = 'bitstream']", NS_PREFIX
      bs_objects.should_not be_empty

      bs_objects.each do |bs_object|
        obj_id_type = bs_object.find_first "P:objectIdentifier/P:objectIdentifierType", NS_PREFIX
        obj_id_type.should_not be_nil
        obj_id_type.content.should == 'URI'

        obj_id_value = bs_object.find_first "P:objectIdentifier/P:objectIdentifierValue", NS_PREFIX
        obj_id_value.should_not be_nil
        obj_id_value.content.should =~ %r(#{subject.uri}/\d+)
      end

    end

    it "should have the sip path inplace for the originalName" do
      doc = XML::Document.string subject['describe-file-object']
      file_object = doc.find_first "/P:object[@xsi:type = 'file']", NS_PREFIX
      file_object.should_not be_nil

      obj_id_type = file_object.find_first "P:originalName", NS_PREFIX
      obj_id_type.should_not be_nil
      obj_id_type.content.should == subject['sip-path']
    end

  end

  it "should take derivation options (migration)" do
    src = subject.wip.datafiles[0]
    dst = subject.wip.datafiles[1]

    src.describe!
    dst.describe! :derivation_source => src.uri, :derivation_method => 'migration'

    doc = XML::Document.string dst['describe-file-object']

    relationship = doc.find_first "P:relationship[P:relatedObjectIdentification/P:relatedObjectIdentifierValue = '#{src.uri}']", NS_PREFIX
    relationship.should_not be_nil

    rel_event = relationship.find_first "P:relatedEventIdentification/P:relatedEventIdentifierValue", NS_PREFIX
    rel_event.should_not be_nil
    event_uri = rel_event.content

    doc = XML::Document.string dst['migration-event']
    event = doc.find_first "/P:event[P:eventIdentifier/P:eventIdentifierValue = '#{event_uri}']", NS_PREFIX
    event.should_not be_nil
    event.find("P:eventType = 'migration'", NS_PREFIX).should be_true

  end

  it "should take derivation options (normalization)" do
    src = subject.wip.datafiles[0]
    dst = subject.wip.datafiles[1]

    src.describe!
    dst.describe! :derivation_source => src.uri, :derivation_method => 'normalization'

    doc = XML::Document.string dst['describe-file-object']

    relationship = doc.find_first "P:relationship[P:relatedObjectIdentification/P:relatedObjectIdentifierValue = '#{src.uri}']", NS_PREFIX
    relationship.should_not be_nil

    rel_event = relationship.find_first "P:relatedEventIdentification/P:relatedEventIdentifierValue", NS_PREFIX
    rel_event.should_not be_nil
    event_uri = rel_event.content

    doc = XML::Document.string dst['normalization-event']
    event = doc.find_first "/P:event[P:eventIdentifier/P:eventIdentifierValue = '#{event_uri}']", NS_PREFIX
    event.should_not be_nil
    event.find("P:eventType = 'normalization'", NS_PREFIX).should be_true

  end
end