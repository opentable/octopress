apt-get update && apt-get install -y curl
curl -L https://get.rvm.io | bash -s stable --ruby=2.0.0-p247
source /usr/local/rvm/scripts/rvm
rvm rubygems latest

cd /vagrant
gem install bundler --no-ri --no-rdoc
gem install rake --no-ri --no-rdoc
bundle install
bundle exec rake install
