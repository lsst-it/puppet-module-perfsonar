require 'spec_helper'

describe 'perfsonar' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it { is_expected.not_to contain_httpauth('psadmin') }
      it { is_expected.not_to contain_file('/etc/profile.d/add_psadmin_pssudo.sh') }

      context 'when with_ipv6 => true' do
        let(:params) { { with_ipv6: true } }

        it { is_expected.to compile }
      end

      context 'when web_admin_password defined' do
        let(:params) { { web_admin_password: 'foobar' } }

        it do
          is_expected.to contain_httpauth('psadmin').with(
            ensure: 'present',
            username: 'admin',
            password: 'foobar',
            file: '/etc/perfsonar/toolkit/psadmin.htpasswd',
            mechanism: 'basic',
          )
        end
      end

      context 'when remove_root_prompt' do
        let(:params) { { remove_root_prompt: true } }

        it { is_expected.to contain_file('/etc/profile.d/add_psadmin_pssudo.sh').with_ensure('absent') }
      end

      context 'when pscheduler_agent_conf is not undef' do
        let(:params) do
          {
            manage_pscheduler_agent: true,
            pscheduler_agent_config: {
              'remotes' => [{
                'url'                => 'https://foo.example.org',
                'configure-archives' => true,
              }],
            },
          }
        end
        let(:config_path) { '/etc/perfsonar/psconfig/pscheduler-agent.json' }

        it do
          is_expected.to contain_file(config_path).with(
            ensure: 'file',
            owner: 'perfsonar',
            group: 'perfsonar',
            mode: '0644',
          )
        end

        it 'converts data into json' do
          mycontent = catalogue.resource('File', config_path)[:content]
          expect(mycontent).to include_json(params[:pscheduler_agent_config])
        end
      end
    end
  end
end
