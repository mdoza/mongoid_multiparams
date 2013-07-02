#
# Copyright (c) 2009-2013 Durran Jordan
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

require "spec_helper"

describe Mongoid::MultiParameterAttributes do

  describe "#process" do

    class Multi
      include Mongoid::Document
      include Mongoid::MultiParameterAttributes
      field :created_at, type: Time
      field :dob, type: Date
      field :checked_at, as: :last_user_checked_at, type: Time
    end

    context "creating a multi" do

      let(:multi) do
        Multi.new(
          "created_at(1i)" => "2010",
          "created_at(2i)" => "8",
          "created_at(3i)" => "12",
          "created_at(4i)" => "15",
          "created_at(5i)" => "45"
        )
      end

      it "sets a multi-parameter Time attribute correctly" do
        multi.created_at.should eq(Time.local(2010, 8, 12, 15, 45))
      end

      it "does not leave ugly attributes on the model" do
        multi.attributes.should_not have_key("created_at(1i)")
      end
    end

    context "creating a multi" do

      context "with a valid DOB" do

        let(:multi) do
          Multi.new({
            "dob(1i)" => "1980",
            "dob(2i)" => "7",
            "dob(3i)" => "27"
          })
        end

        it "sets a multi-parameter Date attribute correctly" do
          multi.dob.should eq(Date.civil(1980, 7, 27))
        end
      end

      context "with an invalid DOB" do

        let(:invalid_multi) do
          Multi.new({
            "dob(1i)" => "1980",
            "dob(2i)" => "2",
            "dob(3i)" => "31"
          })
        end

        it "uses Time's logic to convert the invalid date to valid" do
          invalid_multi.dob.should eq(Time.new(1980, 2, 31).to_date)
        end
      end
    end

    context "with a blank DOB" do

      let(:multi) do
        Multi.new(
          "dob(1i)" => "",
          "dob(2i)" => "",
          "dob(3i)" => ""
        )
      end

      it "generates a nil date" do
        multi.dob.should be_nil
      end
    end

    context "with a partially blank DOB" do

      let(:multi) do
        Multi.new(
          "dob(1i)" => "1980",
          "dob(2i)" => "",
          "dob(3i)" => ""
        )
      end

      it "sets empty date's year" do
        multi.dob.year.should eq(1980)
      end

      it "sets empty date's month" do
        multi.dob.month.should eq(1)
      end

      it "sets empty date's day" do
        multi.dob.day.should eq(1)
      end
    end

    context "with aliased field" do

      let(:multi) do
        Multi.new(
          "last_user_checked_at(1i)" => "2010",
          "last_user_checked_at(2i)" => "8",
          "last_user_checked_at(3i)" => "12",
          "last_user_checked_at(4i)" => "15",
          "last_user_checked_at(5i)" => "45"
        )
      end

      it "sets a multi-parameter Time attribute correctly" do
        multi.last_user_checked_at.should eq(Time.local(2010, 8, 12, 15, 45))
      end

      it "does not leave ugly attributes on the model" do
        multi.attributes.should_not have_key("created_at(1i)")
      end
    end
  end
end
