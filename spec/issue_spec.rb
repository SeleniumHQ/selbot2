require 'spec_helper'

module Selbot2
  class Issues
    describe Issue do

      context "issue blocking another" do
        let(:blocking_issue) { Issue.new(Nokogiri::XML(fixture("blocking_issue.xml")).css("entry").first) }
      
        it "returns the correct url" do
          blocking_issue.url.should == "http://code.google.com/p/selenium/issues/detail?id=7"
        end
      end
      
      context "duplicate issue" do
        let(:duplicate_issue) { Issue.new(Nokogiri::XML(fixture("duplicate_issue.xml")).css("entry").first)}
        
        it "returns the correct url" do
          duplicate_issue.url.should == "http://code.google.com/p/selenium/issues/detail?id=161"
        end
        
        it "knows that the issue is a duplicate" do
          duplicate_issue.should be_duplicate
        end
        
        it "knows the the url of the real issue" do
          duplicate_issue.duplicate_url.should == "http://code.google.com/p/selenium/issues/detail?id=244"
        end
        
      end
    end
  end
end
