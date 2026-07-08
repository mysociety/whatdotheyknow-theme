require_relative 'spec_helper'

RSpec.describe WdtkAreas do
  before { Rails.cache.clear }

  describe '.find' do
    it 'returns the area for a registered slug' do
      expect(described_class.find('isle-of-wight').name).
        to eq('Isle of Wight')
    end

    it 'returns nil for an unknown slug' do
      expect(described_class.find('atlantis')).to be_nil
    end
  end

  describe '.find!' do
    it 'raises RecordNotFound for an unknown slug' do
      expect { described_class.find!('atlantis') }.
        to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe WdtkAreas::Area do
    let(:area) { WdtkAreas.find('isle-of-wight') }

    let!(:council) do
      FactoryBot.create(:public_body, tag_string: 'isle_of_wight local_council')
    end

    let!(:school) do
      FactoryBot.create(:public_body, tag_string: 'isle_of_wight school')
    end

    let!(:unrelated_body) do
      FactoryBot.create(:public_body, tag_string: 'london')
    end

    describe '#public_bodies' do
      it 'only includes bodies tagged with the area tag' do
        expect(area.public_bodies).to match_array([council, school])
      end
    end

    describe '#stats' do
      it 'aggregates the counter cache columns for bodies in the area' do
        FactoryBot.create(:info_request, :successful, public_body: council)
        FactoryBot.create(:info_request, public_body: council)
        FactoryBot.create(:info_request, public_body: unrelated_body)
        [council, unrelated_body].each(&:update_counter_cache)

        stats = area.stats

        expect(stats[:bodies]).to eq(2)
        expect(stats[:requests]).to eq(2)
        expect(stats[:successful]).to eq(1)
      end
    end

    describe '#category_counts' do
      it 'counts bodies in the area per curated category tag' do
        expect(area.category_counts).
          to eq('local_council' => 1, 'school' => 1)
      end

      it 'ignores categories with no bodies in the area' do
        expect(area.category_counts).not_to have_key('police')
      end
    end

    describe '#notable_requests' do
      it 'returns recent successful requests to bodies in the area' do
        successful = FactoryBot.create(:info_request, :successful,
                                       public_body: council)
        FactoryBot.create(:info_request, public_body: school)
        FactoryBot.create(:info_request, :successful,
                          public_body: unrelated_body)

        expect(area.notable_requests).to eq([successful])
      end

      it 'does not include requests that have since been hidden' do
        hidden = FactoryBot.create(:info_request, :successful,
                                   public_body: council)
        area.notable_requests
        hidden.update!(prominence: 'hidden')

        expect(area.notable_requests).to be_empty
      end
    end
  end
end
