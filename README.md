# lnx-vm-net-migrator
after migration linux vm's to another host use this script to change ip, gateway, hostname


# what problem does this script solve?
As a linux engineer you need lots of vm's on your hypervisor in my case vmware. 
Lots of linux vm's means you need to have a way to organize the ip addresses of each one of them
each hostname, and gateways.
After changing the virtual network editor the ip range, dhcp and gateway, one has to change the ip parameters in every vm.
When you move the host to a different ip range, you need to repeat this on every linux vm.

So move this script to your vm, then 
chmod +x changeme.sh
run the script
works with opensuse tumbleweed, sles 15 and leap
