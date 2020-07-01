require 'spec_helper_acceptance'

describe 'erlang init:' do
  case fact('os.family')
  when 'RedHat'
    default_repo_source = 'packagecloud'
    repo_source_list = %w[bintray epel packagecloud erlang_solutions]
  when 'Debian'
    default_repo_source = 'bintray'
    repo_source_list = %w[bintray epel erlang_solutions]
  end

  context 'default class declaration' do
    let(:pp) do
      <<-EOS
      class { 'erlang': }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    describe package('erlang') do
      it { is_expected.to be_installed }
    end
    describe yumrepo("erlang-#{default_repo_source}") do
      it { is_expected.to exist }
      it { is_expected.to be_enabled }
    end
  end

  case fact('os.family')
  when 'RedHat'
    repo_source_list.each do |repo_source|
      context "with repo source set to #{repo_source}" do
        let(:pp) do
          <<-EOS
          class { 'erlang': repo_source => '#{repo_source}' }
          EOS
        end

        it_behaves_like 'an idempotent resource'

        describe package('erlang') do
          it { is_expected.to be_installed }
        end
        describe yumrepo("erlang-#{repo_source}") do
          it { is_expected.to exist }
          it { is_expected.to be_enabled }
        end
      end
    end

    # epel is special in that it enables the epel repo not the erlang-epel repo
    context 'with repo source set to epel' do
      let(:pp) do
        <<-EOS
        class { 'erlang': repo_source => 'epel' }
        EOS
      end

      it_behaves_like 'an idempotent resource'

      describe package('erlang') do
        it { is_expected.to be_installed }
      end
      describe yumrepo('epel') do
        it { is_expected.to exist }
        it { is_expected.to be_enabled }
      end
    end
  when 'Debian'
    repo_source_list.each do |repo_source|
      context "with repo source set to #{repo_source}" do
        let(:pp) do
          <<-EOS
          class { 'erlang': repo_source => '#{repo_source}' }
          EOS
        end

        it_behaves_like 'an idempotent resource'

        describe package('erlang') do
          it { is_expected.to be_installed }
        end
      end
    end
  end
end
