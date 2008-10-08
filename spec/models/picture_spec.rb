require File.dirname(__FILE__) + '/../spec_helper'

describe Picture, "validates_one_picture_per_day" do
  before do
    @picture = Picture.new
    @last_picture = mock_model(Picture, :taken_today? => true)
    Picture.stub!(:find).and_return(@last_picture)
  end
  
  it "should have an error on fb_user_id if a picture exists in the last 2 hours" do
    @picture.should have(1).error_on(:fb_user_id)
  end
  
  it "should have no errors if a picture wasn't taken today" do
    @last_picture.should_receive(:taken_today?).and_return(false)
    @picture.should have(0).error_on(:fb_user_id)
  end
  
  it "should have no errors if this is the first picture" do
    Picture.should_receive(:find).and_return(nil)
    @picture.should have(0).error_on(:fb_user_id)
  end
end

describe Picture, "taken_today?" do
  before do
    @picture = Picture.new
  end
  
  it "should return true if taken today" do
    @picture.stub!(:created_at).and_return(Time.now)
    @picture.taken_today?.should == true
  end
  
  it "should return false if not taken today" do
    @picture.stub!(:created_at).and_return(Time.now - 1.day)
    @picture.taken_today?.should == false
  end
end