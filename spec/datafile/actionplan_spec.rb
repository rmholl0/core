require 'spec_helper'
require 'xmlns'
require 'datafile/describe'
require 'datafile/actionplan'

describe DataFile do

  describe 'when the actionplan server is not available' do

    it 'should raise an error' do

      override_service 'actionplan-url', 500 do
        lambda { subject.normalization }.should raise_error
      end

    end

  end

  describe "with no preservation actions" do

    before :all do
      wip = submit 'mimi'
      @pdf = wip.original_datafiles.find { |df| df['aip-path'] == 'mimi.pdf' }
      @pdf.describe!
    end

    it 'should return nil if there is no migration' do
      @pdf.migration.should be_nil
    end

    it 'should return nil if there is no normalization' do
      @pdf.normalization.should be_nil
    end

    it 'should return nil if there is no xmlresolution' do
      @pdf.xmlresolution.should be_nil
    end

  end

  describe 'with a migration' do
    it 'should redirect to a transformation'
  end

  describe 'with a normalization' do

    before :all do
      wip = submit 'wave'
      @wave = wip.original_datafiles.find { |df| df['aip-path'] == 'obj1.wav' }
      @wave.describe!
    end

    it 'should redirect to a transformation' do
      url = 'http://localhost:7000/transformation/transform/wave_norm'
      @wave.normalization.should == url
    end

  end

  describe 'with a xmlresolution' do

    before :all do
      wip = submit 'wave'
      @xml = wip.original_datafiles.find { |df| df['aip-path'] == 'wave.xml' }
      @xml.describe!
    end

    it 'should not be nil' do
      @xml.xmlresolution.should_not be_nil
    end

  end
end
