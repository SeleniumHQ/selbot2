require 'spec_helper'

module Selbot2
  class Issues
    describe GCodeIssue do
      let(:project_name) { 'selenium' }
      let(:blocking_node) { Nokogiri::XML(fixture("blocking_issue.xml")).css("entry").first }
      let(:blocking_issue) { GCodeIssue.new(blocking_node, project_name) }
      let(:duplicate_node) { Nokogiri::XML(fixture("duplicate_issue.xml")).css("entry").first }
      let(:duplicate_issue) { GCodeIssue.new(duplicate_node, project_name)}
      let(:rx) { Selbot2::Issues::ISSUE_EXP }

      context "issue blocking another" do
        it "returns the correct url" do
          blocking_issue.url.should == "https://code.google.com/p/selenium/issues/detail?id=7"
        end
      end

      context "duplicate issue" do
        it "returns the correct url" do
          duplicate_issue.url.should == "https://code.google.com/p/selenium/issues/detail?id=161"
        end

        it "knows that the issue is a duplicate" do
          duplicate_issue.should be_duplicate
        end

        it "knows the the url of the real issue" do
          duplicate_issue.duplicate_url.should == "https://code.google.com/p/selenium/issues/detail?id=244"
        end
      end

      context "detecting issues references" do
        it "finds selenium issues" do
          "#12323".scan(rx).should == [[nil, "12323"]]
        end

        it "finds google code issues" do
          "chromedriver#12323".scan(rx).should == [["chromedriver", "12323"]]
        end

        it "ignores URL anchors" do
          "http://chromedriver#12323".scan(rx).should == []
        end

        it "finds github issues" do
          "watir/watir-webdriver#12323".scan(rx).should == [["watir/watir-webdriver", "12323"]]
        end

        it "understands parentheses or braces" do
          "(foo#12323)".scan(rx).should == [["foo", "12323"]]
          "(#12323)".scan(rx).should == [[nil, "12323"]]

          "[foo#12323]".scan(rx).should == [["foo", "12323"]]
          "[#12323]".scan(rx).should == [[nil, "12323"]]
        end
      end
    end
  end
end
