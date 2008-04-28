require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper, "display_instructions" do
  before do
    @default = "Take one picture of yourself each day, every day - like #{link_to "this", "http://youtube.com/watch?v=6B26asyGKDo"}."
    @come_back = "Come back tomorrow, and take another picture of yourself."
    @more_options = "More options will be available after you've taken a few more pictures."
    
    self.stub!(:default).and_return(@default)
    self.stub!(:come_back).and_return(@come_back)
    self.stub!(:more_options).and_return(@more_options)
  end
  
  it "should do nothing when nil" do
    display_instructions(nil).should == nil
  end
  
  it "should display default instructions for 0 pictures" do
    display_instructions([]).should == @default
  end
  
  it "should tell user to come back when 1 picture and user has already taken picture today" do
    display_instructions([1], true).should == @come_back
  end
  
  it "should tell user to come back when 2 pictures and user has already taken picture today" do
    display_instructions([1, 2], true).should == @come_back
  end
  
  it "should display default instructions when 1 picture and user has not taken picture today" do
    display_instructions([1]).should == @default
  end
  
  it "should display default instrucitons when 2 pictures and user has not taken picture today" do
    display_instructions([1, 2]).should == @default
  end
  
  it "should tell user about more options when 3 pictures and user has already taken picture today" do
    display_instructions([1, 2, 3], true).should == @more_options
  end
  
  it "should tell user about more options when 4 pictures and user has already taken picture today" do
    display_instructions([1, 2, 3, 4], true).should == @more_options
  end
  
  it "should not display anything if user has taken 3 pictures and has not taken a picture today" do
    display_instructions([1, 2, 3]).should == nil
  end
  
  it "should not display anything if user has taken 4 pictures and has not taken a picture today" do
    display_instructions([1, 2, 3, 4]).should == nil
  end
  
  it "should not display anything if user has taken more than 4 pictures" do
    display_instructions([1, 2, 3, 4, 5]).should == nil
  end

end