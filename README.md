# mikrotik-tf-freedom
Configure your MikroTik via TerraForm to use Freedom.nl internet

## Usage

1. Install [opentofu](https://github.com/opentofu/opentofu)

2. Download provider: `tofu init`

3. Edit [router.tf](./router.tf) and enter your router IP and password.

4. Apply configuration: `tofu apply` (say yes)

    Now you will get some errors like:

    > **Error:** Cannot import non-existent remote object

5. Retrieve IDs from your router by logging in `ssh admin@192.168.88.1` and entering the following commands:

    ```
    :put [/interface/bridge get [print show-ids]]
    :put [/interface/ethernet get [print show-ids]]
    :put [/interface/vlan get [print show-ids]]
    :put [/interface/pppoe-client get [print show-ids]]
    :put [/ip/dhcp-client get [print show-ids]]
    :put [/ip/firewall/nat get [print show-ids]]
    ```

    For example, `:put [/interface/ethernet get [print show-ids]]` will return `*1 R  ether1`. So the ID will be `*1`.

6. Import existing resources (only import the ones that already exist):

    **Make sure you change the ID of commands you need:**

    ```
    tofu import routeros_interface_bridge.ether1 "*1"
    tofu import routeros_interface_ethernet.ether1 "*1"
    tofu import routeros_interface_vlan.bridge-WAN "*9"
    tofu import routeros_interface_pppoe_client.pppoe-client "*A"
    tofu import routeros_ip_dhcp_client.bridge-WAN "*2"
    tofu import routeros_ip_firewall_nat.defconf "*1"
    ```

7. Now you can apply the configuration with `tofu apply`
