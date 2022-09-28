## Purpose

To be a simple but flexible tool to codify and manage sets of configuration options for either a single or multiple machines running MacOS. Use cases include the ability to share full or partial configurations amongst machines (for me... a laptop and a desktop), the ability to create a fleet with identical configs, a cheap and easy way to provision or maintain a fleet of workstations, or just to act as a way to backup or transfer favorite settings to new hardware for an average user. The capabilities are intended to fulfill the requirements of development machines, but every feature-set is opt-in and customizable and dependencies are minimal and static, so reason against using it to provision minimal requirements or anywhere inbetween.

## Usability

### Seperation of executor and options

In order to maximize flexibility and customization of configuration options, this project is designed to operate as two seperate codebases, this particular repo acts as the executor which works alongside another repo (which is built by the user) containing all the configuration variables. Seperation of the two enables anyone to clone and use this project with their own private, version-control, off-site backed up configuration project (or projects).

### Partial

Along with flexibility of being able to customize configurtion options to your liking, this project is also meant to be scalable in terms of how much configuration you actually want it to codify. As such, it's intented to be as close to no-op by default. Said another way, if you don't create any customization variables, then it tries not to make any changes (minus some of the initial bootstraping, installing of dependencies). One of the reasons this is worthy of mentioning is that it also means a configuration set doesn't have to be exhaustive to be useful, and can be implemented partially and scaled incrementally over time. A useful result of this also being that portions can be added or removed without suprising effects to the final result.

### Possible Next Steps

Althought it's not a functionality I currently see a need for (or have any priority around implementing), it does seem like there would be utility in refactoring the variable merge logic to enable a file to codify all resource types related to specific projects, topics, etc. For example, it would load pip packages, VS Code extensions, and clone the repo of a Python project you want to collaborate on. And while it would be hard to implement a simple method to make that reversible when the config file was subtracted, its easy to imagine a solution in that ballpark. If someone ever comes along that sees value enough to engineer a seemless solution, consider it as good as merged.

## Installation

In regards to dependencies: the host must be running MacOS. There are two installation options, each with slightly different (but also minimal) requirements.

## Installation

1. Ensure Apple's command line tools are installed (`xcode-select --install` to launch the installer).
2. [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html):

   1. Run the following command to add Python 3 to your $PATH: `export PATH="$HOME/Library/Python/3.8/bin:/opt/homebrew/bin:$PATH"`
   2. Upgrade Pip: `sudo pip3 install --upgrade pip`
   3. Install Ansible: `pip3 install ansible`

3. Clone or download this repository to your local drive.
4. Run `ansible-galaxy install -r requirements.yml` inside this directory to install required Ansible roles.
5. Run `ansible-playbook main.yml --ask-become-pass` inside this directory. Enter your macOS account password when prompted for the 'BECOME' password.

> Note: If some Homebrew commands fail, you might need to agree to Xcode's license or fix some other Brew issue. Run `brew doctor` to see if this is the case.

### The standard Ansible via python route

There are a few roads that lead to python, the included install script adds its via homebrew, but ultimately this method really only requires ansible, the route is inconsequential.

If easy is the primary goal:

```sh
./install.sh
```

### The snazzy Docker route

There are also a few roads that lead to docker, however the methods I'm aware of don't all lead to exactly the same Docker. That said, fortunatly Docker Desktop (and docker, mostly) on MacOS is actually functional and not the terrible dumpster fire you might have assumed it would be due to past experience with similarly named offerings on other operating systems. It's got a spiffy GUI, there are install options worth having, and not only does it allow you to be a passenger on the thrilling adventure of software installation, being able to install and run Kubernetes in parallel is super handy anytime you find yourself in a situation where hypothermia is a concern.

So even if a convienient install script were to be available (which at this point hopefully its obvious Im speaking hypothetically)... who on Earth would even chose to use it? Although the reasons behind it might not be clear, trust me, I'm actually doing you a favor by choosing not wanting to write a docker script.

So now that you finally seen the light and figured out the one true way to get where you needed to go, and as a result docker is available to fill the one install

## Under the hood

There is no special sauce in this playbook. It's mostly a curated collection of relevant well-designed Ansible roles/collections packaged in a functionality-driven, user-friendly fashion.

## Configuration

### Home

These are a few initial tasks to configure the user home directory. `home_folders` is a list of folders that can created prior to everything else, nesting is possible. `cloned repos` is a list of git repositories to be cloned as well as their destination root at user home. Any nested folders required can be created with `home_folders`

In order to clone private repos, passwordless access should be set up for the user(e.g. via SSH key)

```yaml
home_folders:
  - "Projects"
  - "Test/Nest"

cloned_repos:
  - {
      repo: "https://gitlab.com/donaldrich/ansible-playbooks.git",
      destination: "Projects/ansible-playbooks",
    }
  - {
      repo: "https://gitlab.com/donaldrich/cicdevs.git",
      destination: "Projects/cicdevs",
    }
```

### Dock

Readme: <https://github.com/geerlingguy/ansible-collection-mac/blob/master/roles/dock/README.md>
Module: <https://galaxy.ansible.com/geerlingguy/mac>

```yaml
dockitems_remove:
  - Launchpad
  - TV

dockitems_persist:
  - name: "Sublime Text"
    path: "/Applications/Sublime Text.app/"
    pos: 5
```

### Homebrew

Readme: <https://github.com/geerlingguy/ansible-collection-mac/blob/master/roles/homebrew/README.md>
Module: <https://galaxy.ansible.com/geerlingguy/mac>

Pro-tip: If you're a fan of shell prompts with all the symbols and icons, all the Nerd Fonts can be install as cask apps. And I highly recommend that installation route.

```yaml
homebrew_installed_packages:
  - git

homebrew_cask_apps:
  - altair-graphql-client
```

### App Store

Readme: <https://github.com/geerlingguy/ansible-collection-mac/blob/master/roles/mas/README.md>
Module: <https://galaxy.ansible.com/geerlingguy/mac>

I believe the neccesary authentication is satisfied if your iCloud password is linked to the user. It's probably a safe bet that if you can buy and donload apps in the App Store, this will work.

These app ids can be found in the app store URL.  But the list of all apps that are installed (along with the id) is generated as part of a final report produced during execution. This can be a handy starting point to create a list based on whats currently installed.

```yaml
mas_installed_apps:
  - { id: 497799835, name: "Xcode" }

mas_uninstalled_apps: []
```

### Python & Nodejs

Python Module: <https://galaxy.ansible.com/geerlingguy/pip>

```yaml
pip_install_packages:
  - name: apprise
    state: latest

npm_packages:
  - prettier
```

### VS Code

Personally, I find this is one of the most valuable modules in this set. The VS Code settings sync is great, but not having the extensions installed in parallel can make VS Code really cranky during an initial set up.

The list of install extensions is also generated as part of a final report. And again is helpful to avoid tracking down all these extension ids.

```yaml
visual_studio_code_extensions:
  - redhat.vscode-yaml

visual_studio_code_extensions_absent:
  - streetsidesoftware.code-spell-checker

visual_studio_code_settings_overwrite: no

visual_studio_code_settings: { "files.associations": { "Vagrantfile": "ruby" } }
```

### Sublime Text

```yaml
sublime_config_path: "Packages/User"

sublime_package_control:
  - "DocBlockr"
```

softwareupdate --install-rosetta

### Use with a remote Mac

You can use this playbook to manage other Macs as well; the playbook doesn't even need to be run from a Mac at all! If you want to manage a remote Mac, either another Mac on your network, or a hosted Mac like the ones from [MacStadium](https://www.macstadium.com), you just need to make sure you can connect to it with SSH:

1. (On the Mac you want to connect to:) Go to System Preferences > Sharing.
2. Enable 'Remote Login'.

> You can also enable remote login on the command line:
>
>     sudo systemsetup -setremotelogin on

Then edit the `inventory` file in this repository and change the line that starts with `127.0.0.1` to:

```
[ip address or hostname of mac]  ansible_user=[mac ssh username]
```

If you need to supply an SSH password (if you don't use SSH keys), make sure to pass the `--ask-pass` parameter to the `ansible-playbook` command.

## Testing the Playbook

Use Mac virtualbox <https://github.com/geerlingguy/macos-virtualbox-vm>

## See also

- <https://blog.vandenbrand.org/2016/01/04/how-to-automate-your-mac-os-x-setup-with-ansible/>
- <http://www.nickhammond.com/automating-development-environment-ansible/>
- <https://github.com/simplycycling/ansible-mac-dev-setup/blob/master/main.yml>
- <https://github.com/mas-cli/mas>
- <https://github.com/geerlingguy/mac-dev-playbook>
- <https://github.com/osxc>
- <https://github.com/MWGriffin/ansible-playbooks/blob/master/sourcetree/sourcetree.yaml>
- <https://github.com/sindresorhus/quick-look-plugins>

<https://galaxy.ansible.com/elliotweiser/osx-command-line-tools>
<https://github.com/Geektrovert/AwsTerm>
<https://github.com/topics/apple>
<https://github.com/donnemartin/dev-setup>
<https://github.com/atomantic/dotfiles>

# https://galaxy.ansible.com/elliotweiser/osx-command-line-tools
# https://galaxy.ansible.com/gantsign/oh-my-zsh

# https://galaxy.ansible.com/diodonfrost/p10k

# https://galaxy.ansible.com/gantsign/visual-studio-code

<https://galaxy.ansible.com/sicruse/powerline-fonts>


github.com/scrooloose/nerdtree.git

