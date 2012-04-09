require 'spec_helper'

module Selbot2
  class Issues
    describe Issue do
      let(:project_name) { 'selenium' }
      let(:blocking_node) { Nokogiri::XML(fixture("blocking_issue.xml")).css("entry").first }
      let(:blocking_issue) { Issue.new(blocking_node, project_name) }
      let(:duplicate_node) { Nokogiri::XML(fixture("duplicate_issue.xml")).css("entry").first }
      let(:duplicate_issue) { Issue.new(duplicate_node, project_name)}


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
    end
  end
end
