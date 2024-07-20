# Node Setup
First we need to create a node template in Proxmox

1. Download the ISO using the GUI (tested on https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img)
2. Create the VM via CLI

    ```bash
    # Create base VM
    qm create <VM-ID> --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0
    
    # Move to ISO storage and copy disk in main storage (<YOUR STORAGE HERE> could be local-lvm or other mounted storage)
    cd /var/lib/vz/template/iso/
    qm importdisk <VM-ID> <UBUNTU-ISO-IMG-NAME> <YOUR STORAGE HERE>
    #Example: qm importdisk 5000 [noble-server-cloudimg-amd64.img](https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img) local-lvm
    
    # Create a new disk
    qm set <VM-ID> --scsihw virtio-scsi-pci --scsi0 <YOUR STORAGE HERE>:vm-<VM-ID>-disk-0
    
    # Mount the Cloud Init drive as a CD Drive
    qm set <VM-ID> --ide2 <YOUR STORAGE HERE>:cloudinit
    
    # Set VM to boot from main disk
    qm set <VM-ID> --boot c --bootdisk scsi0
    
    # Attach a display over serial so we can VNC into the node using proxmox UI
    qm set <VM-ID> --serial0 socket --vga serial0
    
    ```

3. Expand the VM disk size to a suitable size (suggested 10 GB)
4. Create the Cloud-Init template
5. Deploy new VMs by cloning the template (full clone)

[Back](../README.md)