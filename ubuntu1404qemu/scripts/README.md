
Description
-----------
 - Setup for split level access where QEMU/KVM VM with embedded VirtFS (9pServer)
   starts within a "management" Docker container (i.e., VE).

 - Therefore, we have three contexts for execution:
    1. Host/native    -- has actual UserIDs and file share directory.

    2. Mgmt/container -- has root or qemuuser UIDs an mapped file share
                             directory from Host/native.
                             This is where the QEMU/KVM is launched.

    3. Guest/vm       -- has root and User1, User2 UIDs and mounts VirtFS 
                             share from the host.

 - As indicated, there are different UserIDs for each context of execution:
    1. Host.root (actually will be Host.docker)
    2. Mgmt.root, Mgmt.qemuuser
    3. Guest.root, Guest.user1, Guest.user2

Objective
---------
 - Test to see if we can run QEMU w/ VirtFS as root within VE,
   i.e., Mgmt.root(qemu), and have proper handling in Guest
   for User1 and User2 when using VirtFS with the 'passthrough' model.

Host Operations
---------------
  1. Host.root: mkdir /var/tmp/users/
  2. Host.root: mkdir /var/tmp/users/user1
  3. Host.root: mkdir /var/tmp/users/user2
  4. Host.root: echo "Hello ALL-USERS" > /var/tmp/users/host_allusers_hello_file
  5. Host.root: echo "Hello USER1"     > /var/tmp/users/user1/host_user1_hello_file
  6. Host.root: echo "Hello USER2"     > /var/tmp/users/user2/host_user2_hello_file
  7. Host.root: chmod a+r   /var/tmp/users/host_allusers_hello_file
  8. Host.root: chmod og-w  /var/tmp/users/host_allusers_hello_file
  9. Host.root: chmod u+rwx /var/tmp/users/user1
  10. Host.root: chmod u+rwx /var/tmp/users/user2
  11. Host.root: chmod u+rw  /var/tmp/users/user1/host_user1_hello_file
  12. Host.root: chmod u+rw  /var/tmp/users/user2/host_user2_hello_file
  13. Host.root: useradd -u 1010 -g 1010 user1
  14. Host.root: useradd -u 2020 -g 2020 user2
  15. Host.root: chown -R user1.user1 /var/tmp/users/user1
  16. Host.root: chown -R user2.user2 /var/tmp/users/user2


VE(Container) Operations
------------------------
  1. Launch VE with /var/tmp/users shared as bind mount
  2. Launch VM with /var/tmp/users attached as the share dir to host
      NOTE: User1 can see User2 dir, but not write and vise versa.

  3. Mgmt.root: useradd -u 107 -g 107 qemuuser 

  - (A) Mgmt.root:  qemu -cdrom 9p_image.iso -sharedir /var/tmp/users
        NOTE: The 'root' should NOT be restricted and should allow Guest to
              write using matching 'user1' or 'user2' UID from Guest VM.

  - (B) Mgmt.qemuuser:  qemu -cdrom 9p_image.iso -sharedir /var/tmp/users
        NOTE: The 'qemuuser' should be restricted and require Guest to
              have matching 'qemuuser' UID from Guest VM.
 

VM(Guest) Operations
--------------------
  1. Guest.root: mount /mnt/hostshare
  2. Guest.root: ls    /mnt/hostshare


  - Read as root
    - Guest.root: cat   /mnt/hostshare/host_allusers_hello_file
    - Guest.root: cat   /mnt/hostshare/users1/host_user1_hello_file
    - Guest.root: cat   /mnt/hostshare/users2/host_user2_hello_file

  - Create as root
    - Guest.root: touch /mnt/hostshare/users/guest_allusers_root_file
    - Guest.root: touch /mnt/hostshare/user1/guest_user1_root_file
    - Guest.root: touch /mnt/hostshare/user2/guest_user2_root_file

  - Write as root
    - Guest.root: echo "Guest root hello" >> /mnt/hostshare/users/guest_allusers_root_file
       - NOTE: If Mgmt.qemuuser,then  should fail.
       - NOTE: If Mgmt.root, then should pass.
  
    - Guest.root: echo "Guest root hello" >> /mnt/hostshare/user1/guest_user1_root_file
       - NOTE: If Mgmt.qemuuser,then should fail.
       - NOTE: If Mgmt.root, then should pass.
  
    - Guest.root: echo "Guest root hello" >> /mnt/hostshare/user2/guest_user2_root_file
       - NOTE: If Mgmt.qemuuser,then should fail.
       - NOTE: If Mgmt.root, then should pass.
  

    ```
    # Read as userX
    # Create as userX
    # Write as userX
  for myuser in user1 user2 ; do 
     su - $myuser
     Guest.$myuser: echo "Guest $myuser hello" >> /mnt/hostshare/users/guest_allusers_root_file
     Guest.$myuser: echo "Guest $myuser hello" >> /mnt/hostshare/user1/guest_user1_root_file
     Guest.$myuser: echo "Guest $myuser hello" >> /mnt/hostshare/user2/guest_user2_root_file
  done
    ```

