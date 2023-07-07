# Collection of Useful Ansible Playbooks

All the playbooks in this repository are tested with `ansible 2.15.1`

## Using the playbooks

### 1. Install python3 and pip

Ansbile 2.15 requires `python >=3.9` and pip to be installed on the control node.

Check if python3 is installed:

```bash
python3 --version
```

If python3 is not installed, install it with:

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.10

python3 --version
# or
python3.10 --version
```

Install pip:

```bash
python3 -m ensurepip --upgrade
# or
python3.10 -m ensurepip --upgrade
```

### 2. Install Ansible

```bash
python3 -m pip install ansible
# or
python3.10 -m pip install ansible
```

Check if ansible is installed:

```bash
ansible --version
```

### 3. Run the playbooks

Each playbook has a script file and a `README.md` file with instructions on how to run it on control node.

To run the playbook using `ansible-playbook` command, refer to [ansible-playbook](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html#ansible-playbook) command
