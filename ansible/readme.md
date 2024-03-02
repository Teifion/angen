# Overview
This is a set of ansible playbooks I created for the purposes of spinning up and deploying Angen servers.

# Instructions
### Create VPS
You will need to spin up 1 or more VPS and handle their DNS settings (e.g. pointing server1.domain.co.uk at the relevant IP).

### Create vault
You will need to create the vault for your project. There is an [example vault](examples/vault.md) with the relevant keys you will need to fill in.
```bash
ansible-vault create vault.txt
```

### Create inventory
Next up you need to create your inventory. As with the vault there is an [example inventory](examples/inventory.yml) you can use as a starting point.
```bash
vi inventory/hosts.yml
```

The servers are divided into two groups, database and web. A server can be both at once or just one.

### Installation
To install you just need to run two commands, the first does a setup for all combined hosts and the second sets up the purely Angen hosts.
```bash
ansible-playbook "playbooks/angen-combo.yml" --extra-vars '@vault.txt'
ansible-playbook "playbooks/angen-web.yml" --extra-vars '@vault.txt'
```

### Deployment
When you build and upload your Angen release you can install it on the relevant nodes with.
```bash
ansible-playbook "playbooks/angen-deploy.yml" --extra-vars '@vault.txt'
```
