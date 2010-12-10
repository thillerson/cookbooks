#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require 'chef/data_bag_item'

describe Chef::DataBagItem do
  before(:each) do
    @data_bag_item = Chef::DataBagItem.new
  end

  describe "initialize" do
    it "should be a Chef::DataBagItem" do
      @data_bag_item.should be_a_kind_of(Chef::DataBagItem)
    end
  end

  describe "data_bag" do
    it "should let you set the data_bag to a string" do
      @data_bag_item.data_bag("clowns").should == "clowns"
    end

    it "should return the current data_bag type" do
      @data_bag_item.data_bag "clowns"
      @data_bag_item.data_bag.should == "clowns"
    end

    it "should not accept spaces" do
      lambda { @data_bag_item.data_bag "clown masters" }.should raise_error(ArgumentError)
    end

    it "should throw an ArgumentError if you feed it anything but a string" do
      lambda { @data_bag_item.data_bag Hash.new }.should raise_error(ArgumentError)
    end
  end

  describe "raw_data" do
    it "should let you set the raw_data with a hash" do
      lambda { @data_bag_item.raw_data = { "id" => "octahedron" } }.should_not raise_error
    end

    it "should let you set the raw_data from a mash" do
      lambda { @data_bag_item.raw_data = Mash.new({ "id" => "octahedron" }) }.should_not raise_error
    end

    it "should raise an exception if you set the raw data without a key" do
      lambda { @data_bag_item.raw_data = { "monkey" => "pants" } }.should raise_error(ArgumentError)
    end

    it "should raise an exception if you set the raw data to something other than a hash" do
      lambda { @data_bag_item.raw_data = "katie rules" }.should raise_error(ArgumentError)
    end

    it "should accept alphanum/-/_ for the id" do
      lambda { @data_bag_item.raw_data = { "id" => "h1-_" } }.should_not raise_error(ArgumentError)
    end

    it "should raise an exception if the id contains anything but alphanum/-/_" do
      lambda { @data_bag_item.raw_data = { "id" => "!@#" } }.should raise_error(ArgumentError)
    end

    it "should return the raw data" do
      @data_bag_item.raw_data = { "id" => "highway_of_emptiness" }
      @data_bag_item.raw_data.should == { "id" => "highway_of_emptiness" }
    end

    it "should be a Mash by default" do
      @data_bag_item.raw_data.should be_a_kind_of(Mash)
    end
  end

  describe "object_name" do
    before(:each) do
      @data_bag_item.data_bag("dreams")
      @data_bag_item.raw_data = { "id" => "the_beatdown" }
    end

    it "should return an object name based on the bag name and the raw_data id" do
      @data_bag_item.object_name.should == "data_bag_item_dreams_the_beatdown"
    end
  end

  describe "class method object_name" do
    it "should return an object name based based on the bag name and an id" do
      Chef::DataBagItem.object_name("zen", "master").should == "data_bag_item_zen_master"
    end
  end

  describe "hash behaviour" do
    before(:each) do
      @data_bag_item.raw_data = { "id" => "journey", "trials" => "been through" }
    end

    it "should respond to keys" do
      @data_bag_item.keys.should include("id")
      @data_bag_item.keys.should include("trials")
    end

    it "should allow lookups with []" do
      @data_bag_item["id"].should == "journey"
    end
  end

  describe "to_hash" do
    before(:each) do 
      @data_bag_item.data_bag("still_lost")
      @data_bag_item.raw_data = { "id" => "whoa", "i_know" => "kung_fu" }
      @to_hash = @data_bag_item.to_hash
    end

    it "should return a hash" do
      @to_hash.should be_a_kind_of(Hash)
    end

    it "should have the raw_data keys as top level keys" do
      @to_hash["id"].should == "whoa"
      @to_hash["i_know"].should == "kung_fu"
    end

    it "should have the chef_type of data_bag_item" do
      @to_hash["chef_type"].should == "data_bag_item"
    end

    it "should have the data_bag set" do
      @to_hash["data_bag"].should == "still_lost"
    end
  end

  describe "deserialize" do
    before(:each) do
      @data_bag_item.data_bag('mars_volta')
      @data_bag_item.raw_data = { "id" => "octahedron", "snooze" => { "finally" => :world_will }}
      @deserial = Chef::JSON.from_json(@data_bag_item.to_json)
    end

    it "should deserialize to a Chef::DataBagItem object" do
      @deserial.should be_a_kind_of(Chef::DataBagItem)
    end

    it "should have a matching 'data_bag' value" do
      @deserial.data_bag.should == @data_bag_item.data_bag
    end

    it "should have a matching 'id' key" do
      @deserial["id"].should == "octahedron"
    end

    it "should have a matching 'snooze' key" do
      @deserial["snooze"].should == { "finally" => "world_will" }
    end
  end
end

