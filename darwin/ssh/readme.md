# Setting up your SSH keys

Say you have two accounts on GitHub

1. Create two pairs of rsa keys using `ssh-keygen`, and name them properly:

```bash
$ ssh-keygen -t rsa -C "email" -f "~/.ssh/key_name"
```

2. Add generated private key (the ones without `.pub`) to the local agent:

```bash
# -K options works for Macs
$ ssh-add -K path_to_private_key

# List private keys
$ ssh-add -l
```

3. Create a `config` file in `~/.ssh/`. Following are sub options of Host:

- `Hostname`
Specify the actual `hostname`, just use `github.com` for github,

- `User`: git
The user is always git for github,

- `IdentityFile`
Specify key to use, just put the path the a public key.

```
Host host_1
    Hostname github.com
    User git
    IdentityFile ~/.ssh/key_1.pub

Host host_2
    Hostname github.com
    User git
    IdentityFile ~/.ssh/key_2.pub
```

4. For existing repos:

- For repo in Host `host_1`:

```bash
$ git remote set-url origin git@host_1:user/repo.git
```

- For repo in Host `host_2`:

```bash
$ git remote set-url origin git@host_2:user/repo.git
```

5. Cloning new repos

```bash
# add the Host name instead of github.com
$ git clone git@host_1:user/repo.git
```
