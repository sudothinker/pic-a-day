require File.dirname(__FILE__) + '/../spec_helper'

describe "misc specs" do
  controller_name :ads

  it "should save the picture as a full image of size 480x360" do
  
  end

  it "should save the picture as a profile thumbnail of size 360x270" do
  
  end

  it "should save the picture as a small thumbnail of size 80x60" do
  
  end

  it "should save the pictures in JPG format" do
  
  end

  it "should store the pictures inside a directory named after the user's unique id" do
  
  end

  it "should name the pictures in the format of 'month_day_year_dimensions.jpg' (ex: 4_8_2008_480x360.jpg for a 480x360 picture taken on April 8, 2008)" do
  
  end


  # canvas page

  it "should switch from Camera mode to Thumbnail mode when you click on a thumbnail" do
  
  end

  it "should switch from Thumbnail mode to Camera mode when you click on the 'Take Picture' button" do
  
  end


  it "should allow the user to take a picture if he hasn't taken one today" do
  
  end

  it "should not allow the user to take a picture if he already took one today" do
  
  end

  it "should allow the user to delete a picture" do
  
  end

  it "should allow the user to delete today's picture and retake it" do
  
  end

  it "should switch to Camera mode if user deleted today's picture" do
  
  end

  it "should allow the user to delete a previous picture but not retake it" do
  
  end
end