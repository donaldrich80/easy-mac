# Installing Xcode Command Line Tools
xcode-select --install

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew doctor

# Install python3
brew install python
echo 'export PATH="/usr/local/opt/python/libexec/bin:$PATH"' >>~/.zshrc
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# Install PIP
# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# sudo python get-pip.py

# Install Ansible
sudo pip install ansible
brew install git
