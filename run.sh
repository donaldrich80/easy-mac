#!/bin/bash

ansible-galaxy collection install -r requirements.yml
ansible-galaxy install -r requirements.yml

ansible-playbook -i inventory -K playbook.yml


