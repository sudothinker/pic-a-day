require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper, "display_instructions" do
  before do
    
    @default = "Take a picture of yourself everyday - like <a href=\"#\" clicktoshowdialog=\"youtube\" title=\"Click to view\">this</a>."
    @come_back = "Come back tomorrow, and take another picture of yourself."
    @more_options = "More to come after you've taken a few more pictures."
    
    self.stub!(:default).and_return(@default)
    self.stub!(:come_back).and_return(@come_back)
    self.stub!(:more_options).and_return(@more_options)
    @pictures = mock('pictures', :total_entries => 0)
  end
  
  it "should do nothing when nil" do
    display_instructions(nil).should == nil
  end
  
  it "should display default instructions for 0 pictures" do
    display_instructions(@pictures).should include(@default)
  end
  
  it "should tell user to come back when 1 picture and user has already taken picture today" do
    @pictures.stub!(:total_entries).and_return(1)
    display_instructions(@pictures, true).should include(@come_back)
  end
  
  it "should tell user to come back when 2 pictures and user has already taken picture today" do
    @pictures.stub!(:total_entries).and_return(2)
    display_instructions(@pictures, true).should include(@come_back)
  end
  
  it "should display default instructions when 1 picture and user has not taken picture today" do
    @pictures.stub!(:total_entries).and_return(1)    
    display_instructions(@pictures).should include(@default)
  end
  
  it "should display default instrucitons when 2 pictures and user has not taken picture today" do
    @pictures.stub!(:total_entries).and_return(2)    
    display_instructions(@pictures).should include(@default)
  end
  
  it "should tell user about more options when 3 pictures and user has already taken picture today" do
    @pictures.stub!(:total_entries).and_return(3)    
    display_instructions(@pictures, true).should include(@more_options)
  end
  
  it "should tell user about more options when 4 pictures and user has already taken picture today" do
    @pictures.stub!(:total_entries).and_return(4)    
    display_instructions(@pictures, true).should include(@more_options)
  end
  
  it "should not display anything if user has taken 3 pictures and has not taken a picture today" do
    @pictures.stub!(:total_entries).and_return(3)    
    display_instructions(@pictures).should == nil
  end
  
  it "should not display anything if user has taken 4 pictures and has not taken a picture today" do
    @pictures.stub!(:total_entries).and_return(4)    
    display_instructions(@pictures).should == nil
  end
  
  it "should not display anything if user has taken more than 4 pictures" do
    @pictures.stub!(:total_entries).and_return(5)    
    display_instructions(@pictures).should == nil
  end

end