# laptop-bootstrap

This repo contains a bash script to set up development environments for new HeavyWater team members.

This is a public repo intended automate the steps to access to the private install scripts in the [hw-cli](https://github.com/HeavyWater-Solutions/hw-cli) repository.

## Instructions

Run the following in a terminal window:

```bash
bash <(curl -s https://raw.githubusercontent.com/HeavyWater-Solutions/laptop-bootstrap/master/bootstrap.sh)
```

As the final step of the bootstrap script, the `laptop-install` shell script in the [hw-cli](https://github.com/HeavyWater-Solutions/hw-cli) repository is called to complete installation of required developer tools.
