require 'spec_helper'

describe 'When running ansible playbooks' do

  playbooks = Dir.glob('playbooks/*yml') - ['playbooks/common.yml']
  environments = Dir.glob('environments/*/inventory')

  playbooks.each do |playbook|
    environments.each do |env|
      it "should run #{playbook} on env #{env.split('/')[1]} \
          ansible playbooks in check syntax mode" do

        ansible_command = "ansible-playbook -i #{env} --connection=local \
                           --syntax-check #{playbook}"
        expect(command(ansible_command).exit_status).to eq 0
      end
    end

  end

end
