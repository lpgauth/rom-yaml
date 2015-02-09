require 'spec_helper'

require 'rom/lint/spec'

describe 'YAML adapter' do
  subject(:rom) { setup.finalize }

  let(:root) { Pathname(__FILE__).dirname.join('..') }

  let(:path) { "#{root}/fixtures/test_db.yml" }
  let(:setup) { ROM.setup(:yaml, path) }

  before do
    setup.relation(:users) do
      def by_name(name)
        dataset.find_all { |user| user[:name] == name }
      end
    end

    setup.mappers do
      define(:users) do
        model name: 'User'

        attribute :name
        attribute :email

        embedded :roles, type: :array do
          attribute :name, from: 'role_name'
        end
      end
    end
  end

  describe 'env#read' do
    it 'returns mapped object' do
      jane = rom.read(:users).by_name('Jane').first

      expect(jane.name).to eql('Jane')
      expect(jane.email).to eql('jane@doe.org')
      expect(jane.roles.length).to eql(2)
      expect(jane.roles).to eql([
        { name: 'Member' } , { name: 'Admin' }
      ])
    end
  end
end
