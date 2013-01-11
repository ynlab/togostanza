# coding: utf-8

require 'spec_helper'

describe StanzaBase do
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
      }
    end

    subject { klass.new(bar: 'bar').context }

    it {
      should == {
        foo: 'foo',
        bar: 'barbarbar',
        baz: {qux: 'quux'}
      }
    }
  end
end
