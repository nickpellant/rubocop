# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::ModuleLength, :config do
  let(:cop_config) { { 'Max' => 5, 'CountComments' => false } }

  it 'rejects a module with more than 5 lines' do
    expect_offense(<<~RUBY)
      module Test
      ^^^^^^^^^^^ Module has too many lines. [6/5]
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  it 'reports the correct beginning and end lines' do
    inspect_source(<<~RUBY)
      module Test
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
        a = 6
      end
    RUBY
    offense = cop.offenses.first
    expect(offense.location.first_line).to eq(1)
    expect(offense.location.last_line).to eq(8)
  end

  it 'accepts a module with 5 lines' do
    expect_no_offenses(<<~RUBY)
      module Test
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
      end
    RUBY
  end

  it 'accepts a module with less than 5 lines' do
    expect_no_offenses(<<~RUBY)
      module Test
        a = 1
        a = 2
        a = 3
        a = 4
      end
    RUBY
  end

  it 'does not count blank lines' do
    expect_no_offenses(<<~RUBY)
      module Test
        a = 1
        a = 2
        a = 3
        a = 4


        a = 7
      end
    RUBY
  end

  it 'accepts empty modules' do
    expect_no_offenses(<<~RUBY)
      module Test
      end
    RUBY
  end

  context 'when a module has inner modules' do
    it 'does not count lines of inner modules' do
      expect_no_offenses(<<~RUBY)
        module NamespaceModule
          module TestOne
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          module TestTwo
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
        end
      RUBY
    end

    it 'rejects a module with 6 lines that belong to the module directly' do
      expect_offense(<<~RUBY)
        module NamespaceModule
        ^^^^^^^^^^^^^^^^^^^^^^ Module has too many lines. [6/5]
          module TestOne
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          module TestTwo
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when a module has inner classes' do
    it 'does not count lines of inner classes' do
      expect_no_offenses(<<~RUBY)
        module NamespaceModule
          class TestOne
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          class TestTwo
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
        end
      RUBY
    end

    it 'rejects a module with 6 lines that belong to the module directly' do
      expect_offense(<<~RUBY)
        module NamespaceModule
        ^^^^^^^^^^^^^^^^^^^^^^ Module has too many lines. [6/5]
          class TestOne
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          class TestTwo
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when CountComments is enabled' do
    before { cop_config['CountComments'] = true }

    it 'also counts commented lines' do
      expect_offense(<<~RUBY)
        module Test
        ^^^^^^^^^^^ Module has too many lines. [6/5]
          a = 1
          #a = 2
          a = 3
          #a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when inspecting a class defined with Module.new' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Foo = Module.new do
        ^^^ Module has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end
end