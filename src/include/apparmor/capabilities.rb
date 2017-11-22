# encoding: utf-8

# ***************************************************************************
#
# Copyright (c) 2002 - 2012 Novell, Inc.
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#
# ***************************************************************************
#
#  YCP map containing definitons for Capabiltiies
#
module Yast
  module ApparmorCapabilitiesInclude
    def initialize_apparmor_capabilities(include_target)
      textdomain "apparmor"

      @capdefs = {
        "chown"            => {
          "name" => "CAP_CHOWN",
          "info" => _(
            "<ul><li>In a system with the [_POSIX_CHOWN_RESTRICTED] option defined, \n" +
              "this overrides the restriction of changing file ownership \n" +
              "and group ownership.</li></ul>"
          )
        },
        "dac_override"     => {
          "name" => "CAP_DAC_OVERRIDE",
          "info" => _(
            "<ul><li>Override all DAC access, including ACL execute access if \n[_POSIX_ACL] is defined. Excluding DAC access covered by CAP_LINUX_IMMUTABLE.</li></ul>"
          )
        },
        "dac_read_search"  => {
          "name" => "CAP_DAC_READ_SEARCH",
          "info" => _(
            "<ul><li>Overrides all DAC restrictions regarding read and search \n" +
              "on files and directories, including ACL restrictions if [_POSIX_ACL] is defined. \n" +
              "Excluding DAC access covered by CAP_LINUX_IMMUTABLE. </li></ul>"
          )
        },
        "fowner"           => {
          "name" => "CAP_FOWNER",
          "info" => _(
            "<ul><li>Overrides all restrictions on allowed operations on files, where file\n" +
              "owner ID must be equal to the user ID, except where CAP_FSETID is\n" +
              "applicable. It does not override MAC and DAC restrictions. </li></ul>"
          )
        },
        "fsetid"           => {
          "name" => "CAP_FSETID",
          "info" => _(
            "<ul><li>Overrides the following restrictions: user ID must match the file owner ID when setting the S_ISUID and S_ISGID bits on that file; the effective group ID (or one of the supplementary group IDs) must match the file owner ID when setting the S_ISGID bit on that file; the S_ISUID and S_ISGID bits are cleared on successful return from chown(2) (not implemented). </li></ul>"
          )
        },
        "kill"             => {
          "name" => "CAP_KILL",
          "info" => _(
            "<ul><li>Overrides the restriction that the real or effective user ID \n" +
              "of a process sending a signal must match the real or effective user ID of the process \n" +
              "receiving the signal.</li></ul>"
          )
        },
        "setgid"           => {
          "name" => "CAP_SETGID",
          "info" => _(
            "<ul><li>Allows setgid(2) manipulation </li> <li> Allows setgroups(2) </li> \n<li> Allows forged gids on socket credentials passing. </li></ul>"
          )
        },
        "setuid"           => {
          "name" => "CAP_SETUID",
          "info" => _(
            "<ul><li>Allows setuid(2) manipulation (including fsuid) </li> \n<li> Allows forged pids on socket credentials passing. </li></ul>"
          )
        },
        "setpcap"          => {
          "name" => "CAP_SETPCAP",
          "info" => _(
            "<ul><li> Transfer any capability in your permitted set to any pid, \nremove any capability in your permitted set from any pid</li></ul>"
          )
        },
        "linux_immutable"  => {
          "name" => "CAP_LINUX_IMMUTABLE",
          "info" => _(
            "<ul><li>Allows modification of S_IMMUTABLE and S_APPEND file attributes</li></ul>"
          )
        },
        "net_bind_service" => {
          "name" => "CAP_NET_BIND_SERVICE",
          "info" => _(
            "<ul><li>Allows binding to TCP/UDP sockets below 1024 </li> \n<li> Allows binding to ATM VCIs below 32</li></ul>"
          )
        },
        "net_broadcast"    => {
          "name" => "CAP_NET_BROADCAST",
          "info" => _(
            "<ul><li> Allows broadcasting, listen to multicast </li></ul>"
          )
        },
        "net_admin"        => {
          "name" => "CAP_NET_ADMIN",
          "info" => _(
            "<ul><li> Allows interface configuration</li> \n" +
              "<li> Allows administration of IP firewall, masquerading and accounting</li> \n" +
              "<li> Allows setting debug option on sockets</li> \n" +
              "<li> Allows modification of routing tables</li>"
          ) +
            _(
              "<li> Allows setting arbitrary process / process group ownership on sockets</li> \n" +
                "<li> Allows binding to any address for transparent proxying</li> \n" +
                "<li> Allows setting TOS (type of service)</li> \n" +
                "<li> Allows setting promiscuous mode</li> \n" +
                "<li> Allows clearing driver statistics</li>"
            ) +
            _(
              "<li> Allows multicasting</li> \n" +
                "<li> Allows read/write of device-specific registers</li> \n" +
                "<li> Allows activation of ATM control sockets </li>\n" +
                "</ul>"
            )
        },
        "net_raw"          => {
          "name" => "CAP_NET_RAW",
          "info" => _(
            "<ul><li> Allows use of RAW sockets</li> \n<li> Allows use of PACKET sockets </li></ul>"
          )
        },
        "ipc_lock"         => {
          "name" => "CAP_IPC_LOCK",
          "info" => _(
            "<ul><li> Allows locking of shared memory segments</li> <li> Allows mlock and\nmlockall (which does not really have anything to do with IPC) </li></ul>"
          )
        },
        "ipc_owner"        => {
          "name" => "CAP_IPC_OWNER",
          "info" => _("<ul><li> Override IPC ownership checks </li></ul>")
        },
        "sys_module"       => {
          "name" => "CAP_SYS_MODULE",
          "info" => _(
            "<ul><li> Insert and remove kernel modules - modify kernel without limit</li> \n<li> Modify cap_bset </li></ul>"
          )
        },
        "sys_rawio"        => {
          "name" => "CAP_SYS_RAWIO",
          "info" => _(
            "<ul><li> Allows ioperm/iopl access</li> \n<li> Allows sending USB messages to any device via /proc/bus/usb </li></ul>"
          )
        },
        "sys_chroot"       => {
          "name" => "CAP_SYS_CHROOT",
          "info" => _("<ul><li> Allows use of chroot() </li></ul>")
        },
        "sys_ptrace"       => {
          "name" => "CAP_SYS_PTRACE",
          "info" => _("<ul><li> Allows ptrace() of any process </li></ul>")
        },
        "sys_pacct"        => {
          "name" => "CAP_SYS_PACCT",
          "info" => _(
            "<ul><li> Allows configuration of process accounting </li></ul>"
          )
        },
        "sys_admin"        => {
          "name" => "CAP_SYS_ADMIN",
          "info" => _(
            "<ul><li> Allows configuration of the secure attention key</li> \n" +
              "<li> Allows administration of the random device</li> \n" +
              "<li> Allows examination and configuration of disk quotas</li> \n" +
              "<li> Allows configuring the kernel's syslog (printk behaviour)</li>"
          ) +
            _(
              "<li> Allows setting the domain name</li> \n" +
                "<li> Allows setting the hostname</li> \n" +
                "<li> Allows calling bdflush()</li> \n" +
                "<li> Allows mount() and umount(), setting up new smb connection</li> \n" +
                "<li> Allows some autofs root ioctls</li>"
            ) +
            _(
              "<li> Allows nfsservctl</li> \n" +
                "<li> Allows VM86_REQUEST_IRQ</li> \n" +
                "<li> Allows to read/write pci config on alpha</li> \n" +
                "<li> Allows irix_prctl on mips (setstacksize)</li> \n" +
                "<li> Allows flushing all cache on m68k (sys_cacheflush)</li>"
            ) +
            _(
              "<li> Allows removing semaphores</li> \n" +
                "<li> Used instead of CAP_CHOWN to \"chown\" IPC message queues, semaphores and shared memory</li> \n" +
                "<li> Allows locking/unlocking of shared memory segment</li> \n" +
                "<li> Allows turning swap on/off</li> \n" +
                "<li> Allows forged pids on socket credentials passing</li>"
            ) +
            _(
              "<li> Allows setting read ahead and flushing buffers on block devices</li> \n" +
                "<li> Allows setting geometry in floppy driver</li> \n" +
                "<li> Allows turning DMA on/off in xd driver</li> \n" +
                "<li> Allows administration of md devices (mostly the above, but some extra ioctls)</li>"
            ) +
            _(
              "<li> Allows tuning the ide driver</li> \n" +
                "<li> Allows access to the nvram device</li> \n" +
                "<li> Allows administration of apm_bios, serial and bttv (TV) device</li> \n" +
                "<li> Allows manufacturer commands in iaan CAPI support driver</li>"
            ) +
            _(
              "<li> Allows reading non-standardized portions of pci configuration space</li> \n" +
                "<li> Allows DDI debug ioctl on sbpcd driver</li> \n" +
                "<li> Allows setting up serial ports</li> \n" +
                "<li> Allows sending raw qic-117 commands</li>"
            ) +
            _(
              "<li> Allows enabling/disabling tagged queuing on SCSI controllers\n" +
                " and sending arbitrary SCSI commands</li> \n" +
                "<li> Allows setting encryption key on loopback filesystem </li></ul>"
            )
        },
        "sys_boot"         => {
          "name" => "CAP_SYS_BOOT",
          "info" => _("<ul><li> Allows use of reboot() </li></ul>")
        },
        "sys_nice"         => {
          "name" => "CAP_SYS_NICE",
          "info" => _(
            "<ul><li> Allows raising priority and setting priority on other (different UID) processes</li> \n" +
              "<li> Allows use of FIFO and round-robin (realtime) scheduling on own processes and setting \n" +
              "the scheduling algorithm used by another process.</li> \n" +
              "<li> Allows setting cpu affinity on other processes </li></ul>"
          )
        },
        "sys_resource"     => {
          "name" => "CAP_SYS_RESOURCE",
          "info" => _(
            "<ul><li> Override resource limits. Set resource limits.</li> \n" +
              "<li> Override quota limits.</li> \n" +
              "<li> Override reserved space on ext2 filesystem</li> \n" +
              "<li> Modify data journaling mode on ext3 filesystem (uses journaling resources)</li>"
          ) +
            _(
              "<li> NOTE: ext2 honors fsuid when checking for resource overrides, so you can override using fsuid too</li> \n" +
                "<li> Override size restrictions on IPC message queues</li> \n" +
                "<li> Allows more than 64hz interrupts from the real-time clock</li> \n" +
                "<li> Override max number of consoles on console allocation</li> \n" +
                "<li> Override max number of keymaps </li></ul>"
            )
        },
        "sys_time"         => {
          "name" => "CAP_SYS_TIME",
          "info" => _(
            "<ul><li> Allows manipulation of system clock</li> \n" +
              "<li> Allows irix_stime on mips</li> \n" +
              "<li> Allows setting the real-time clock </li></ul>"
          )
        },
        "sys_tty_config"   => {
          "name" => "CAP_SYS_TTY_CONFIG",
          "info" => _(
            "<ul><li> Allows configuration of tty devices</li> \n<li> Allows vhangup() of tty </li></ul>"
          )
        },
        "mknod"            => {
          "name" => "CAP_MKNOD",
          "info" => _(
            "<ul><li> Allows the privileged aspects of mknod() </li></ul>"
          )
        },
        "lease"            => {
          "name" => "CAP_LEASE",
          "info" => _("<ul><li> Allows taking of leases on files </li></ul>")
        }
      }


      @linnametolp = {
        "CAP_CHOWN"            => "chown",
        "CAP_DAC_OVERRIDE"     => "dac_override",
        "CAP_DAC_READ_SEARCH"  => "dac_read_search",
        "CAP_FOWNER"           => "fowner",
        "CAP_FSETID"           => "fsetid",
        "CAP_KILL"             => "kill",
        "CAP_SETGID"           => "setgid",
        "CAP_SETUID"           => "setuid",
        "CAP_SETPCAP"          => "setpcap",
        "CAP_LINUX_IMMUTABLE"  => "linux_immutable",
        "CAP_NET_BIND_SERVICE" => "net_bind_service",
        "CAP_NET_BROADCAST"    => "net_broadcast",
        "CAP_NET_ADMIN"        => "net_admin",
        "CAP_NET_RAW"          => "net_raw",
        "CAP_IPC_LOCK"         => "ipc_lock",
        "CAP_IPC_OWNER"        => "ipc_owner",
        "CAP_SYS_MODULE"       => "sys_module",
        "CAP_SYS_RAWIO"        => "sys_rawio",
        "CAP_SYS_CHROOT"       => "sys_chroot",
        "CAP_SYS_PTRACE"       => "sys_ptrace",
        "CAP_SYS_PACCT"        => "sys_pacct",
        "CAP_SYS_ADMIN"        => "sys_admin",
        "CAP_SYS_BOOT"         => "sys_boot",
        "CAP_SYS_NICE"         => "sys_nice",
        "CAP_SYS_RESOURCE"     => "sys_resource",
        "CAP_SYS_TIME"         => "sys_time",
        "CAP_SYS_TTY_CONFIG"   => "sys_tty_config",
        "CAP_MKNOD"            => "mknod",
        "CAP_LEASE"            => "lease"
      }
    end
  end
end
