# coding: utf-8

require 'spec_helper'

describe StanzaBase do
  describe '.property' do
    let(:klass) { Class.new(StanzaBase) }

    specify 'raise error when specify a value and block' do
      expect {
        klass.property :foo, 'bar' do
          'baz'
        end
      }.to raise_error(ArgumentError)
    end

    specify 'raise error when neither specify a value nor block' do
      expect {
        klass.property :foo
      }.to raise_error(ArgumentError)
    end

    specify 'allow specify a falsy value' do
      klass.property :foo, false

      klass.properties[:foo].should == false
    end
  end

  describe '#context' do
    let :klass do
      Class.new(StanzaBase) {
        property :foo do
          'foo'
        end

        property :bar do |bar|
          bar * 3
        end

        property :baz do
          {
            qux: 'quux'
          }
        end

        property :foobar, 'foobar'
      }
    end

    subject { klass.new(bar: 'bar').context }

    it {
      should == {
        foo:    'foo',
        bar:    'barbarbar',
        baz:    {qux: 'quux'},
        foobar: 'foobar'
      }
    }
  end
end
