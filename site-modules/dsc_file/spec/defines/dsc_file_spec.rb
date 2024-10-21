require 'spec_helper'

describe 'dsc_file' do
  let(:title) { 'test' }

  on_supported_os.each do |_os, facts|
    let(:facts) do
      facts
    end

    let(:params) do
      {
        dsc_destinationpath: 'C:/test.txt',
      }
    end

    it do
      is_expected.to contain_dsc('test').with_resource_name('MSFT_FileDirectoryConfiguration')
                                        .with_properties(%r{DestinationPath.*=>.*C:/test\.txt})
    end
  end
end
