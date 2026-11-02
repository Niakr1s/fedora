# Post install

## Enabling TRIM on Encrypted (LUKS) Devices

1. Identify your active LUKS mapper name:

   ```
   lsblk
   ```

   Look for the `crypt` type entry under your disk partition (e.g., `luks-1e647929-62c0-4922-8944-f941ed4155fd`).

2. Enable persistent discard passthrough on the active LUKS mapping:

   ```
   sudo cryptsetup --allow-discards --persistent refresh <mapper_name>
   ```
3. Reboot your system to apply the changes.

4. Verify that discard passthrough is active:

   ```
   lsblk -D
   sudo fstrim -v /
   ```

   `lsblk -D` should now display non-zero values under `DISC-GRAN` and `DISC-MAX` for your encrypted volume, and `fstrim` will output the amount of trimmed space rather than skipping the device.
