require File.dirname(__FILE__) + '/../spec_helper'

describe "misc specs" do
  controller_name :pictures

  it "should save the picture as a full image of size 480x360" do
  
  end

  it "should save the picture as a profile thumbnail of size 360x270" do
  
  end

  it "should save the picture as a small thumbnail of size 80x60" do
  
  end

  it "should save the pictures in JPG format" do
  
  end

  it "should name the pictures in the format of 'facebook_user_id_month_day_year_dimensions.jpg' (ex: 23423_4_8_2008_480x360.jpg for a 480x360 picture taken on April 8, 2008 for user 23423)" do
  
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
  
  
  # profile page
  
  it "should show the user's picture if user took one today" do
    
  end
  
  it "should show an empty silhouette if the user has not taken a picture today" do
    
  end
  
end