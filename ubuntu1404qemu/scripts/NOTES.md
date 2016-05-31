NOTES
-----
  - Note, I wrote basic setup script for the host ("host_setup.sh") that
    creates two users and some files for the host share directory.
    (See script "host_setup.sh", run from within Host context)

  - Note, I startup the Docker VE as a "system VE" running 'sleep infinity'
    so that I can easily attach using exec and launch the QEMU manually.
    (See script "mgmtVE_setup.sh", run from within Docker VE context)

  - When I launch VM within the VE, I can not SSH to localhost:10027
    from the Host (outside the VE).  This is likely fixable by passing
    an arg during Docker startup for the VE, but would need to be addressed.
    For now, I am just testing by running from within VE 
    (i.e., "docker exec -ti devel_qemu bash")

  - Note, see QEMU variable in 'mgmtVE_setup.sh' for setting if using
    QEMU (emulation) or QEMU/KVM (hardware enabled).

  - Must make sure to launch the VE with the proper host share dir
    passed in so that it can be shared up to the VM.
    For example, in current setup this would be '/var/tmp/users'
    passed during Docker launch.
    For now, I am just keeping that path the same in the Docker context,
    i.e., bind mount arg for Docker is "-v /var/tmp/users:/var/tmp/users"

