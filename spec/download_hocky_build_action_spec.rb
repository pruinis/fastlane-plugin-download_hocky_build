describe Fastlane::Actions::DownloadHockyBuildAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The download_hocky_build plugin is working!")

      Fastlane::Actions::DownloadHockyBuildAction.run(nil)
    end
  end
end
