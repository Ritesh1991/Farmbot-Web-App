require 'spec_helper'

describe Api::ImagesController do
  include Devise::Test::ControllerHelpers
  let(:user) { FactoryGirl.create(:user) }

  describe '#index' do
    it 'shows only the max images allowed' do
      sign_in user
      device = user.device
      # Using the *real* value (10) was super slow (~30 seconds)
      device.update_attributes!(max_images_count: 1)
      FactoryGirl.create_list(:image, 2, device: user.device)
      get :index
      expect(response.status).to eq(200)
      expect(json.length).to eq(device.max_images_count)
      expect(json.first.key?(:attachment_url)).to be_truthy
    end
  end

  describe '#show' do
    it 'shows image meta data' do
      sign_in user
      image = FactoryGirl.create(:image, device: user.device)
      get :show, params: { id: image.id }
      expect(response.status).to eq(200)
      expect(json[:id]).to eq(image.id)
      expect(json[:device_id]).to eq(user.device_id)
      expect(json[:meta]).to be_truthy
      expect(json.key?(:attachment_url)).to be_truthy
    end
  end

  describe "#create" do
    it 'creates one image' do
      sign_in user
      before_count = Image.count
      post :create,
           body: { attachment_url: "https://placeholdit.imgix.net/~text?txt"\
                                   "size=5&txt=1%C3%971&w=1&h=1&txtpad=1",
                   meta: { x: 1, y: 2, z: 3 } }.to_json,
           params: {format: :json}
      expect(response.status).to eq(200)
      expect(Image.count).to be > before_count
      expect(json[:device_id]).to eq(user.device.id)
      expect(json.key?(:attachment_processed_at)).to be_truthy
      expect(json[:attachment_url]).to include("placehold")
      expect(json.dig :meta, :x).to eq(1)
      expect(json.dig :meta, :y).to eq(2)
      expect(json.dig :meta, :z).to eq(3)
    end

    describe '#delete' do
      it 'deletes an image' do
        sign_in user
        image = FactoryGirl.create(:image, device: user.device)
        before_count = Image.count
        delete :destroy, params: { id: image.id }
        expect(response.status).to eq(200)
        expect(Image.count).to be < before_count
      end
    end
  end
end
