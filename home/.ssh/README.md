# SSH keys for two GitHub accounts

Use one key per account, and one host alias per key.

1. Make a key for each account:

   ```bash
   ssh-keygen -t ed25519 -C "<email>" -f ~/.ssh/<key_name>
   ```

2. Add the public key (`<key_name>.pub`) to the account on GitHub.

3. Add a host alias for each key to `~/.ssh/config`. `IdentityFile` is the
   private key, the file without `.pub`:

   ```
   Host host_1
       Hostname github.com
       User git
       IdentityFile ~/.ssh/key_1

   Host host_2
       Hostname github.com
       User git
       IdentityFile ~/.ssh/key_2
   ```

4. Use the alias in place of `github.com`:

   ```bash
   git clone git@host_1:user/repo.git                  # a new repo
   git remote set-url origin git@host_1:user/repo.git  # a repo you have
   ```

The ssh-agent keeps the key after the first use, because `~/.ssh/config` sets
`AddKeysToAgent`. To see the keys in the agent, run `ssh-add -l`.
