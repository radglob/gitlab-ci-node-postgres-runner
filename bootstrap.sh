# Provisioning file for Gitlab runner Vagrant box.
apt-get update

# Install needed packages.
apt-get install -y curl build-essential libssl-dev git

# Get Gitlab runner .deb
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.deb.sh | sudo bash

# Install Gitlab runner.
apt-get install -y gitlab-ci-multi-runner

# Install node, postgres on system.
export HOME=/home/vagrant
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.25.4/install.sh | bash

echo "source ~/.nvm/nvm.sh" >> /home/vagrant/.bashrc
source /home/vagrant/.nvm/nvm.sh

nvm install 0.12.4
nvm alias default 0.12.4
nvm use default

chown -R vagrant:vagrant /home/vagrant/.nvm

echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
sudo apt-key add -
sudo apt-get update

apt-get install -y postgresql-9.4

# Set environment variables for Postgres.
echo 'export PGUSER="runner"' >> /home/vagrant/.bashrc
echo 'export PGPASSWORD="runner_pass"' >> /home/vagrant/.bashrc
echo 'export PGDATABASE="testdb"' >> /home/vagrant/.bashrc

source ~/.bashrc

# Create database and user.
sudo -u postgres psql template1 -c "create database testdb;"
sudo -u postgres psql template1 -c "create user runner password 'runner_pass' superuser;"

# Fix for Ubuntu bug with running gitlab runner.
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl
