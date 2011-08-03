require File.expand_path(File.dirname(__FILE__) + '/../lib/object_factory.rb')
require "active_record"
require "active_support/core_ext/class/attribute_accessors"

class TestClass
  attr_accessor :field, :another_field, :password, :password_confirmation, :other, :other_confirmation
  cattr_accessor :accessible_attributes, :protected_attributes

  def initialize parameters = nil
    self.field = parameters[:field]
    self.another_field = parameters[:another_field]
    self.password = parameters[:password]
    self.password_confirmation = parameters[:password_confirmation]
  end
end

class AnotherTestClass
  cattr_accessor :accessible_attributes, :protected_attributes
end

class User < ActiveRecord::Base
  attr_accessible :status, :firstname,:lastname
  validates_presence_of :login
end

class Blog < ActiveRecord::Base
  attr_protected :tag
end

ActiveRecord::Base.configurations = {
  'db1' => {
    :adapter  => 'sqlite3',
    :encoding => 'utf8',
    :database => 'object_tests',
  }
}

ActiveRecord::Base.establish_connection('db1')

def create_tables
  User.connection.drop_table('users') if User.connection.table_exists?(:users)
  User.connection.create_table :users do |u|
    u.string :status
    u.string :firstname
    u.string :lastname
    u.string :gender
    u.datetime :login_at
    u.string :login
    u.string :type
  end

  Blog.connection.drop_table('blogs') if User.connection.table_exists?(:blogs)
  Blog.connection.create_table :blogs do |b|
    b.string :title
    b.string :content
    b.string :tag
  end
end

def define_factories
  Object.factory.when_creating_a(User,
    :generate => {
      :status => lambda { 'active' },
      :firstname => lambda { 'frodo' },
      :lastname => lambda { 'baggins' },
      :gender => lambda { 'male' },
      :login => lambda { 'fg' }
    }
  )

  Object.factory.when_creating_a(Blog,
    :generate => {
      :title => lambda { 'wheels of time' },
      :content => lambda { 'wheels_of_time'},
      :tag => lambda { 'fantasy' }
    }
  )
end

describe Object, "with RSpec/Rails extensions" do
  describe "accessing the factory" do
    it "should return an object factory" do
      Object.factory.class.should == Object::Factory
    end

    it "should use a single instance" do
      @first_factory = Object.factory
      @second_factory = Object.factory

      @first_factory.should == @second_factory
    end
  end
end

describe Object::Factory::ValueGenerator do
  it "should generate a unique string value for a given class and field" do
    @generator = Object::Factory::ValueGenerator.new

    @value = @generator.value_for TestClass, :field
    @value.should match(/TestClass\-field\-(\d+)/)
  end

  it "should generate a unique integer value" do
    @generator = Object::Factory::ValueGenerator.new

    @first_value = @generator.unique_integer
    @second_value = @generator.unique_integer

    @first_value.should_not == @second_value
  end

end

describe Object::Factory, "creating simple instances" do

  before :each do
    Object.factory.reset
    create_tables()
    define_factories()
  end

  it "should create an instance of the given class with no provided parameters" do
    @created_instance = Object.factory.create_a(TestClass)
    @created_instance.class.should == TestClass
  end

  it "should create an instance of the given class with the given parameters" do
    @created_instance = Object.factory.create_a(TestClass, :some => :values)
    @created_instance.class.should == TestClass
  end

  it "should allow 'a' as a short-cut to creating objects" do
    @created_instance = a TestClass
    @created_instance.class.should == TestClass
  end

  it "should allow 'an' as a short-cut to creating objects" do
    @created_instance = an User
    @created_instance.firstname.should == "frodo"
  end

  it "should auto-save the created object" do
    @created_instance = a_saved User
    @created_instance.firstname.should == "frodo"

    @created_instance.new_record?.should == false
  end

  it "should raise an exception if the auto-saved object cannot be saved" do
    lambda {
      @created_instance = a_saved(User, :login => nil)
    }.should raise_error(Object::Factory::CannotSaveError)
  end

  it "should allow 'a_saved' as a short-cut to creating and saving an object" do
    @created_instance = a_saved User
    @created_instance.firstname.should == "frodo"
  end
end

describe Object::Factory, "configuring a class" do
  it "should allow 'when_creating_a' as a short-cut to configuring a class" do
    Object.factory.should_receive(:when_creating_a)

    when_creating_a TestClass, :auto_generate => :employee_code
  end
end

describe Object::Factory, "creating instances with generated values" do

  before :each do
    Object.factory.reset
  end

  it "should auto-generate a unique value for a configured field" do
    Object.factory.generator.should_receive(:value_for).with(TestClass, :field).and_return("TestClass-field-1")

    Object.factory.when_creating_a TestClass, :auto_generate => :field
    @instance = Object.factory.create_a TestClass
    @instance.field.should == 'TestClass-field-1'
  end

  it "should auto-generate unique values for multiple configured fields" do
    Object.factory.generator.should_receive(:value_for).with(TestClass, :field).and_return("TestClass-field-1")
    Object.factory.generator.should_receive(:value_for).with(TestClass, :another_field).and_return("TestClass-another_field-1")

    Object.factory.when_creating_a TestClass, :auto_generate => [:field, :another_field]

    @instance = Object.factory.create_a TestClass
    @instance.field.should match(/TestClass-field-(\d+)/)
    @instance.another_field.should match(/TestClass-another_field-(\d+)/)
  end

  it "should allow you to override generated values" do
    Object.factory.when_creating_a TestClass, :auto_generate => :field

    @instance = Object.factory.create_a TestClass, :field => 'My Override Value'
    @instance.field.should == 'My Override Value'
  end

  it "should allow you to override generated values with nils" do
    Object.factory.when_creating_a TestClass, :auto_generate => :field

    @instance = Object.factory.create_a TestClass, :field => nil
    @instance.field.should be_nil
  end

end

describe Object::Factory, "creating instances with overriden values using a block" do
  before do
    Object.factory.when_creating_a TestClass, :set => {:field => "fred"}
    create_tables()
  end

  context "with a do/end block" do
    it "should allow you to override generated values using a block" do
      @instance = Object.factory.create_a TestClass do |tc|
        tc.field = "My override value"
      end
      @instance.field.should == "My override value"
    end

    it "should allow you to override generated values when creating using a block" do
      define_factories
      @instance = Object.factory.create_and_save_a(User) do |tc|
        tc.firstname = "lannister"
      end
      @instance.firstname.should == "lannister"
    end
  end

  context "with an inline block" do
    it "should allow you to override generated values using a block" do
      @instance = Object.factory.create_a(TestClass) { |tc| tc.field = "My override value" }
      @instance.field.should == "My override value"
    end

    it "should allow you to override generated values when creating using a block" do
      define_factories
      @instance = Object.factory.create_and_save_a(User) { |tc| tc.firstname = "lannister" }
      @instance.firstname.should == "lannister"
    end
  end

end

describe Object::Factory, "creating instances with confirmed values" do

  before :each do
    Object.factory.reset
  end

  it "should auto-generate a unique value for a configured field and its confirmation field" do
    Object.factory.generator.should_receive(:value_for).with(TestClass, :password).and_return("TestClass-password-1")

    Object.factory.when_creating_a TestClass, :auto_confirm => :password

    @instance = Object.factory.create_a TestClass
    @instance.password.should == 'TestClass-password-1'
    @instance.password_confirmation.should == @instance.password
  end

  it "should auto-generate unique values for multiple configured fields and confirmation fields" do
    Object.factory.generator.should_receive(:value_for).with(TestClass, :password).and_return("TestClass-password-1")
    Object.factory.generator.should_receive(:value_for).with(TestClass, :other).and_return("TestClass-other-1")

    Object.factory.when_creating_a TestClass, :auto_confirm => [:password, :other]

    @instance = Object.factory.create_a TestClass
    @instance.password.should match(/TestClass-password-(\d+)/)
    @instance.password_confirmation.should == @instance.password
    @instance.other.should match(/TestClass-other-(\d+)/)
    @instance.other_confirmation.should == @instance.other
  end

  it "should allow you to override confirmed original values" do
    Object.factory.when_creating_a TestClass, :auto_confirm => :password

    @instance = Object.factory.create_a TestClass, :password => 'My Override Value'
    @instance.password.should == 'My Override Value'
    @instance.password_confirmation.should_not == @instance.password
  end

  it "should allow you to override confirmed confirmation fields" do
    Object.factory.when_creating_a TestClass, :auto_confirm => :password

    @instance = Object.factory.create_a TestClass, :password_confirmation => 'My Override Value'
    @instance.password_confirmation.should == 'My Override Value'
    @instance.password_confirmation.should_not == @instance.password
  end

  it "should allow you to override confirmed values with nils" do
    Object.factory.when_creating_a TestClass, :auto_confirm => :password

    @instance = Object.factory.create_a TestClass, :password => nil
    @instance.password.should be_nil
    @instance.password_confirmation.should_not == @instance.password
  end

  it "should allow you to override confirmed confirmation fields with nils" do
    Object.factory.when_creating_a TestClass, :auto_confirm => :password

    @instance = Object.factory.create_a TestClass, :password_confirmation => nil
    @instance.password_confirmation.should be_nil
    @instance.password_confirmation.should_not == @instance.password
  end
end

describe Object::Factory, "setting static values" do
  before :each do
    Object.factory.reset
  end

  it "should set a static value for a configured field" do
    Object.factory.when_creating_a TestClass, :set => { :field => 'hello' }
    @instance = Object.factory.create_a TestClass
    @instance.field.should == 'hello'
  end

  it "should set static values for multiple configured fields" do
    Object.factory.when_creating_a TestClass, :set => { :field => 'hello', :another_field => 'world' }

    @instance = Object.factory.create_a TestClass
    @instance.field.should == 'hello'
    @instance.another_field.should == 'world'
  end
end

describe Object::Factory, "generating email addresses" do
  before :each do
    Object.factory.reset
  end

  it "should generate a random email address for a configured field" do
    Object.factory.when_creating_a TestClass, :generate_email_address => :field

    @instance = Object.factory.create_a TestClass
    @instance.field.should match(/(.*)@(.*)\.com/)
  end

  it "should generate random email addresses for multiple configured fields" do
    Object.factory.when_creating_a TestClass, :generate_email_address => [:field, :another_field]

    @instance = Object.factory.create_a TestClass
    @instance.field.should match(/(.*)@(.*)\.com/)
    @instance.another_field.should match(/(.*)@(.*)\.com/)
  end
end

describe Object::Factory, "generating ip addresses" do
  before :each do
    Object.factory.reset
  end

  it "should generate a random ip address for a configured field" do
    Object.factory.when_creating_a TestClass, :generate_ip_address => :field

    @instance = Object.factory.create_a TestClass
    @instance.field.should match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
  end

  it "should generate a random ip address for multiple configured fields" do
    Object.factory.when_creating_a TestClass, :generate_ip_address => [:field, :another_field]

    @instance = Object.factory.create_a TestClass
    @instance.field.should match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
    @instance.another_field.should match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
  end
end

describe Object::Factory, "invoking after create callback" do
  before(:each) do
    Object.factory.reset
  end

  it "should invoke the callback after creating the object" do
    t = nil
    Object.factory.when_creating_a AnotherTestClass, :after_create => lambda { |u|
      t = u
    }

    @test_instance = AnotherTestClass.new()
    AnotherTestClass.should_receive(:new).with({}).and_return(@test_instance)
    @test_instance.should_receive(:save).and_return(true)

    @instance = Object.factory.create_and_save_a AnotherTestClass
    t.should_not be_nil
  end
end

describe Object::Factory, "Should bypass mass-assignment protection" do
  before(:each) do
    Object.factory.reset
    create_tables()
    define_factories
  end

  it "should be possible to override protected attributes via attr_accessible" do
    user = Object.factory.create_and_save_a(User, :firstname => 'foo', :login => 'bar')
    user.firstname.should == 'foo'
    user.lastname.should == 'baggins'
    user.login.should == 'bar'
  end

  it "should be possible to override protected attributes via attr_protected" do
    blog = a_saved(Blog, :tag => "high_fantasy")
    blog.title.should == "wheels of time"
    blog.tag.should == "high_fantasy"
    blog.content.should == "wheels_of_time"
  end

  it "should be possible to define protected attributes" do
    blog = a_saved Blog
    blog.tag.should == "fantasy"
  end
end

describe Object::Factory, "using lambdas to generate values" do
  before :each do
    Object.factory.reset
  end

  it "should set a lambda-generator for configured fields" do
    Object.factory.when_creating_a TestClass, :generate => { :field => lambda { "poop" }, :another_field => lambda { Date.today.to_s } }

    @instance = Object.factory.create_a TestClass
    @instance.field.should == 'poop'
    @instance.another_field.should == Date.today.to_s
  end
end

describe Object::Factory, "generating sequential numbers" do
  before :each do
    Object.factory.reset
  end

  it "should generate a sequential number" do
    first = Object.factory.next_number
    second = Object.factory.next_number

    second.should == first + 1
  end

  it "should use the shortcut to generate a sequential number" do
    Object.factory.should_receive(:next_number).and_return(1)
    number = a_number
  end
end

describe Object::Factory, "cleaning up ActiveRecord models" do
  unless defined?(ActiveRecord)
    module ActiveRecord
      class Base
      end
    end
  end

  before :each do
    Object.factory.reset
  end

  it "should delete all instances for registered classes" do
    # Quack like ActiveRecord::Base as if our lives depended on it.
    # Easier than just depending on it? Probably.
    [TestClass, AnotherTestClass].each do |klass|
      klass.class_eval do
        def self.ancestors
          super | [ActiveRecord::Base]
        end
        def self.respond_to? meffod, *args
          return true if meffod == :with_exclusive_scope || meffod == :delete_all
          super
        end
        def self.with_exclusive_scope
          yield
        end
      end
    end

    TestClass.ancestors.should include(ActiveRecord::Base)
    TestClass.respond_to?(:with_exclusive_scope).should be_true
    TestClass.respond_to?(:delete_all).should be_true

    AnotherTestClass.ancestors.should include(ActiveRecord::Base)
    AnotherTestClass.respond_to?(:with_exclusive_scope).should be_true
    AnotherTestClass.respond_to?(:delete_all).should be_true

    Object.factory.when_creating_a TestClass, :auto_confirm => :password, :clean_up => true
    Object.factory.when_creating_an AnotherTestClass, :clean_up => true

    TestClass.should_receive(:delete_all).and_return(0)
    AnotherTestClass.should_receive(:delete_all).and_return(0)

    Object.factory.clean_up
  end
end
