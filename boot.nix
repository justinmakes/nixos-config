# For btrfs on luks: must give grub the uuid of the partition the crypt device is written to.
  # (nvme0n1p2 in this case)
  # nvme0n1p2 part 07129496-ae5d-4ec3-9ace-d99e45e60650

{
boot.initrd.luks.devices = {
  root = {
    device = "/dev/disk/by-uuid/07129496-ae5d-4ec3-9ace-d99e45e60650";
    allowDiscards = true; # allow TRIM requests to the underlying device
  };
};
}
