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
module Yast
  module ApparmorProfileDialogsInclude
    def initialize_apparmor_profile_dialogs(include_target)
      Yast.import "UI"
      Yast.import "Wizard"
      Yast.import "Popup"
      Yast.import "Label"
      Yast.import "Map"
      Yast.include include_target, "apparmor/capabilities.rb"
      textdomain "apparmor"

      # Globalz
      @timeout_millisec = 20 * 1000
      @Settings = { "CURRENT_PROFILE" => "" }
    end

    def capabilityEntryPopup(capmap, linuxcapname, profile)
      capmap = deep_copy(capmap)
      results = {}
      lpname = Ops.get(@linnametolp, linuxcapname, "")
      cdef = Ops.get(@capdefs, lpname)
      caplist = []
      capbool = false
      Builtins.foreach(@linnametolp) do |clname, clpname|
        capbool = true if Ops.get(capmap, clpname) != nil
        caplist = Builtins.add(caplist, Item(Id(clname), clname, capbool))
        capbool = false
      end
      info = Ops.get_locale(
        cdef,
        "info",
        _(
          "<b>Capability Selection</b>.\n" +
            "<br>Select desired capabilities for this profile. \n" +
            "Select a Capability name to see information about the capability."
        )
      )
      frametitle = Ops.add(
        Ops.add("  " + _("Capabilities enabled for the profile") + " ", profile),
        "   "
      )
      UI.OpenDialog(
        VBox(
          HSpacing(75),
          VSpacing(Opt(:hstretch), 1),
          HBox(
            VSpacing(20),
            HSpacing(0.5),
            Frame(
              frametitle,
              HBox(
                HWeight(
                  30,
                  MultiSelectionBox(
                    Id(:caps),
                    Opt(:notify),
                    _("Capabilities"),
                    caplist
                  )
                ),
                HWeight(60, RichText(Id(:captext), info))
              )
            ),
            HSpacing(0.05)
          ),
          VSpacing(0.5),
          HBox(
            HWeight(50, HCenter(PushButton(Id(:save), Label.OKButton))),
            HWeight(50, HCenter(PushButton(Id(:cancel), Label.CancelButton)))
          ),
          VSpacing(Opt(:hstretch), 0.5)
        )
      )

      if linuxcapname != ""
        UI.ChangeWidget(Id(:caps), :CurrentItem, linuxcapname)
      end

      event2 = {}
      id2 = nil
      begin
        event2 = UI.WaitForEvent(@timeout_millisec)
        id2 = Ops.get(event2, "ID") # We'll need this often - cache it
        if id2 == :caps
          itemid = UI.QueryWidget(Id(:caps), :CurrentItem)
          selecteditems = Convert.to_list(
            UI.QueryWidget(Id(:caps), :SelectedItems)
          )
          stritem = Builtins.tostring(itemid)
          capindex = Ops.get(@linnametolp, stritem, "")
          cdf = Ops.get(@capdefs, capindex)
          cdfi = Ops.get_string(cdf, "info", "")
          UI.ChangeWidget(Id(:captext), :Value, cdfi)
        end
      end until id2 == :save || id2 == :cancel

      newcapmap = {}
      if id2 == :save
        selectedcaps = Convert.to_list(
          UI.QueryWidget(Id(:caps), :SelectedItems)
        )
        s = ""
        Builtins.foreach(selectedcaps) do |cpname|
          s = Ops.get(@linnametolp, Builtins.tostring(cpname), "")
          newcapmap = Builtins.add(newcapmap, s, { "audit" => 0, "set" => 1 })
        end
      end
      UI.CloseDialog
      return deep_copy(capmap) if id2 == :cancel
      deep_copy(newcapmap)
    end


    def networkEntryPopup(rule)
      listnum = 0
      netlist = Builtins.splitstring(rule, " ")
      netrulesize = Builtins.size(netlist)
      family = ""
      sockettype = ""
      if netrulesize == 1
        family = "All"
      elsif netrulesize == 2
        family = Ops.get_string(netlist, 1, "")
      elsif netrulesize == 3
        family = Ops.get_string(netlist, 1, "")
        sockettype = Ops.get_string(netlist, 2, "")
      end

      famList = [
        Item(Id(:allfam), _("All")),
        Item(Id(:inet), "inet"),
        Item(Id(:inet6), "inet6"),
        Item(Id(:ax25), "ax25"),
        Item(Id(:ipx), "ipx"),
        Item(Id(:appletalk), "appletalk"),
        Item(Id(:netrom), "netrom"),
        Item(Id(:bridge), "bridge"),
        Item(Id(:atmpvc), "atmpvc"),
        Item(Id(:x25), "x25"),
        Item(Id(:rose), "rose"),
        Item(Id(:netbeui), "netbeui"),
        Item(Id(:security), "security"),
        Item(Id(:key), "key"),
        Item(Id(:packet), "packet"),
        Item(Id(:ash), "ash"),
        Item(Id(:econet), "econet"),
        Item(Id(:atmsvc), "atmsvc"),
        Item(Id(:sna), "sna"),
        Item(Id(:irda), "irda"),
        Item(Id(:ppox), "pppox"),
        Item(Id(:wanpipe), "wanpipe"),
        Item(Id(:bluetooth), "bluetooth")
      ]

      typeList = [
        Item(Id(:alltype), _("All")),
        Item(Id(:stream), "stream"),
        Item(Id(:dgram), "dgram"),
        Item(Id(:seqpacket), "seqpacket"),
        Item(Id(:rdm), "rdm"),
        Item(Id(:raw), "raw"),
        Item(Id(:packet), "packet"),
        Item(Id(:dccp), "dccp")
      ]

      results = {}

      UI.OpenDialog(
        VBox(
          VSpacing(1),
          HBox(
            HCenter(
              ComboBox(
                Id(:famItems),
                Opt(:notify),
                _("Network Family"),
                famList
              )
            ),
            HSpacing(Opt(:hstretch), 0.2),
            HCenter(
              ComboBox(Id(:typeItems), Opt(:notify), _("Socket Type"), typeList)
            )
          ),
          VSpacing(1),
          HBox(
            HCenter(PushButton(Id(:cancel), Label.CancelButton)),
            HCenter(PushButton(Id(:save), Label.SaveButton))
          ),
          VSpacing(0.5)
        )
      )

      if rule == "" || family == "All"
        UI.ChangeWidget(:famItems, :Value, :allfam)
        UI.ChangeWidget(:typeItems, :Value, :alltype)
        UI.ChangeWidget(:typeItems, :Enabled, false)
      else
        if family != ""
          UI.ChangeWidget(
            :famItems,
            :Value,
            Builtins.symbolof(Builtins.toterm(family))
          )
        end
        if sockettype != ""
          UI.ChangeWidget(
            :typeItems,
            :Value,
            Builtins.symbolof(Builtins.toterm(sockettype))
          )
        end
      end
      event2 = {}
      id2 = nil
      begin
        event2 = UI.WaitForEvent(@timeout_millisec)
        id2 = Ops.get(event2, "ID") # We'll need this often - cache it
        if id2 == :famItems
          if UI.QueryWidget(:famItems, :Value) == :allfam
            UI.ChangeWidget(:typeItems, :Value, :alltype)
            UI.ChangeWidget(:typeItems, :Enabled, false)
          else
            UI.ChangeWidget(:typeItems, :Enabled, true)
          end
        end
      end until id2 == :save || id2 == :cancel
      if id2 == :save
        rule = "network"
        famselection = Convert.to_symbol(UI.QueryWidget(:famItems, :Value))
        typeselection = Convert.to_symbol(UI.QueryWidget(:typeItems, :Value))
        if famselection != :allfam
          rule = Ops.add(
            Ops.add(rule, " "),
            Builtins.substring(Builtins.tostring(famselection), 1)
          )
          if typeselection != :alltype
            rule = Ops.add(
              Ops.add(rule, " "),
              Builtins.substring(Builtins.tostring(typeselection), 1)
            )
          end
        end
      else
        rule = ""
      end
      UI.CloseDialog
      rule
    end


    #
    # Popup the Edit Profile Entry dialog
    # return a map containing PERM and FILE
    # for the updated permissions and filename
    # for the profile entry
    #

    def pathEntryPopup(filename, perms, profile, filetype)
      results = {}
      UI.OpenDialog(
        VBox(
          VSpacing(Opt(:hstretch), 1),
          HSpacing(45),
          HBox(
            VSpacing(10),
            HSpacing(0.75),
            Frame(
              Ops.add(_("Profile Entry for "), profile),
              HBox(
                HWeight(
                  60,
                  VBox(
                    TextEntry(Id(:filename), _("Enter or Modify Filename")),
                    HCenter(PushButton(Id(:browse), _("&Browse")))
                  )
                ),
                HWeight(
                  40,
                  MultiSelectionBox(
                    Id(:perms),
                    Opt(:notify),
                    _("Permissions"),
                    [
                      Item(
                        Id(:read),
                        _("Read"),
                        Builtins.issubstring(perms, "r")
                      ),
                      Item(
                        Id(:write),
                        _("Write"),
                        Builtins.issubstring(perms, "w")
                      ),
                      Item(
                        Id(:link),
                        _("Link"),
                        Builtins.issubstring(perms, "l")
                      ),
                      Item(
                        Id(:append),
                        _("Append"),
                        Builtins.issubstring(perms, "a")
                      ),
                      Item(
                        Id(:lock),
                        _("Lock"),
                        Builtins.issubstring(perms, "k")
                      ),
                      Item(
                        Id(:mmap),
                        _("MMap PROT_EXEC"),
                        Builtins.issubstring(perms, "m")
                      ),
                      Item(
                        Id(:execute),
                        _("Execute"),
                        Builtins.issubstring(perms, "x")
                      ),
                      Item(
                        Id(:inherit),
                        _("Inherit"),
                        Builtins.issubstring(perms, "i")
                      ),
                      Item(
                        Id(:profile),
                        _("Profile"),
                        Builtins.issubstring(perms, "p")
                      ),
                      Item(
                        Id(:clean_profile),
                        _("Profile Clean Exec"),
                        Builtins.issubstring(perms, "P")
                      ),
                      Item(
                        Id(:unconstrained),
                        _("Unconstrained"),
                        Builtins.issubstring(perms, "u")
                      ),
                      Item(
                        Id(:clean_unconstrained),
                        _("Unconstrained Clean Exec"),
                        Builtins.issubstring(perms, "U")
                      )
                    ]
                  )
                )
              )
            ),
            HSpacing(0.75)
          ),
          VSpacing(0.5),
          HBox(
            HWeight(50, HCenter(PushButton(Id(:save), Label.OKButton))),
            HWeight(50, HCenter(PushButton(Id(:cancel), Label.CancelButton)))
          ),
          VSpacing(Opt(:hstretch), 0.5)
        )
      )
      UI.ChangeWidget(Id(:filename), :Value, filename)
      event2 = {}
      id2 = nil
      begin
        event2 = UI.WaitForEvent(@timeout_millisec)
        id2 = Ops.get(event2, "ID") # We'll need this often - cache it

        #
        # Something clicked in the 'perms list
        #
        if id2 == :perms
          itemid = UI.QueryWidget(Id(:perms), :CurrentItem)
          selecteditems = Convert.to_list(
            UI.QueryWidget(Id(:perms), :SelectedItems)
          )
          if itemid == :execute
            #
            # If we turn off Execute bit then also
            # turn off execute modifiers
            #
            if Builtins.contains(selecteditems, :execute) == false
              if Builtins.contains(selecteditems, :inherit)
                selecteditems = Builtins.filter(selecteditems) do |k|
                  k != :inherit
                end
                UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
              end
              if Builtins.contains(selecteditems, :profile)
                selecteditems = Builtins.filter(selecteditems) do |k|
                  k != :profile
                end
                UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
              end
              if Builtins.contains(selecteditems, :unconstrained)
                selecteditems = Builtins.filter(selecteditems) do |k|
                  k != :unconstrained
                end
                UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
              end
              if Builtins.contains(selecteditems, :clean_unconstrained)
                selecteditems = Builtins.filter(selecteditems) do |k|
                  k != :clean_unconstrained
                end
                UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
              end
              if Builtins.contains(selecteditems, :clean_profile)
                selecteditems = Builtins.filter(selecteditems) do |k|
                  k != :clean_profile
                end
                UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
              end
            elsif !(Builtins.contains(selecteditems, :inherit) ||
                Builtins.contains(selecteditems, :unconstrained) ||
                Builtins.contains(selecteditems, :clean_unconstrained) ||
                Builtins.contains(selecteditems, :clean_profile) ||
                Builtins.contains(selecteditems, :profile))
              #if you just select X alone then by default you get P
              selecteditems = Builtins.prepend(selecteditems, :profile)
              UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
            end
          end

          #
          # Execute modifier is selected
          #  -- if Execute is NOT ON then turn Execute ON
          #  -- ensure that only one modifier is selected.
          #
          if Builtins.contains(selecteditems, :inherit) ||
              Builtins.contains(selecteditems, :clean_unconstrained) ||
              Builtins.contains(selecteditems, :clean_profile) ||
              Builtins.contains(selecteditems, :unconstrained) ||
              Builtins.contains(selecteditems, :profile)
            if Builtins.contains(selecteditems, :execute) == false
              selecteditems = Builtins.prepend(selecteditems, :execute)
              UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
            elsif itemid == :profile
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :inherit
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :clean_unconstrained
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :clean_profile
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :unconstrained
              end
              UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
            elsif itemid == :inherit
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :profile
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :unconstrained
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :clean_unconstrained
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :clean_profile
              end
              UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
            elsif itemid == :unconstrained
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :profile
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :inherit
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :clean_unconstrained
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :clean_profile
              end
              UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
            elsif itemid == :clean_unconstrained
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :profile
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :inherit
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :unconstrained
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :clean_profile
              end
              UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
            elsif itemid == :clean_profile
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :profile
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :inherit
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :clean_unconstrained
              end
              selecteditems = Builtins.filter(selecteditems) do |k|
                k != :unconstrained
              end
              UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
            end
          elsif Builtins.contains(selecteditems, :execute)
            selecteditems = Builtins.filter(selecteditems) { |k| k != :execute }
            UI.ChangeWidget(Id(:perms), :SelectedItems, selecteditems)
          end
        end
        #
        # Popup a dialog to let a user browse for a file
        #
        if id2 == :browse
          selectfilename = ""
          if filetype == "dir"
            selectfilename = UI.AskForExistingDirectory(
              "/",
              _("Select Directory")
            )
          else
            selectfilename = UI.AskForExistingFile("/", "", _("Select File"))
          end
          if selectfilename != nil
            UI.ChangeWidget(Id(:filename), :Value, selectfilename)
          end
        end
      end until id2 == :save || id2 == :cancel

      if id2 == :cancel
        UI.CloseDialog
        return nil
      end

      #
      # Update table values
      #
      if id2 == :save
        selectedbits = Convert.to_list(
          UI.QueryWidget(Id(:perms), :SelectedItems)
        )
        newperms = ""
        if Builtins.contains(selectedbits, :write)
          newperms = Ops.add(newperms, "w")
        end
        if Builtins.contains(selectedbits, :mmap)
          newperms = Ops.add(newperms, "m")
        end
        if Builtins.contains(selectedbits, :read)
          newperms = Ops.add(newperms, "r")
        end
        if Builtins.contains(selectedbits, :link)
          newperms = Ops.add(newperms, "l")
        end
        if Builtins.contains(selectedbits, :lock)
          newperms = Ops.add(newperms, "k")
        end
        if Builtins.contains(selectedbits, :append)
          newperms = Ops.add(newperms, "a")
        end
        if Builtins.contains(selectedbits, :execute)
          if Builtins.contains(selectedbits, :profile)
            newperms = Ops.add(newperms, "p")
          elsif Builtins.contains(selectedbits, :inherit)
            newperms = Ops.add(newperms, "i")
          elsif Builtins.contains(selectedbits, :unconstrained)
            newperms = Ops.add(newperms, "u")
          elsif Builtins.contains(selectedbits, :clean_unconstrained)
            newperms = Ops.add(newperms, "U")
          elsif Builtins.contains(selectedbits, :clean_profile)
            newperms = Ops.add(newperms, "P")
          end
          newperms = Ops.add(newperms, "x")
        end
        filename = Builtins.tostring(UI.QueryWidget(Id(:filename), :Value))
        UI.CloseDialog
        if filename == "" || newperms == ""
          Popup.Error(
            _("Entry will not be added. Entry name or permissions not defined.")
          )
          results = nil
        else
          results = { "PERM" => newperms, "FILE" => filename }
        end
      end
      deep_copy(results)
    end

    def fileEntryPopup(filename, perms, profile)
      pathEntryPopup(filename, perms, profile, "file")
    end

    def dirEntryPopup(filename, perms, profile)
      pathEntryPopup(filename, perms, profile, "dir")
    end


    def deleteNetworkRule(netRules, rule)
      netRules = deep_copy(netRules)
      audit = Ops.get_map(netRules, "audit", {})
      rules = Ops.get_map(netRules, "rule", {})
      netlist = Builtins.splitstring(rule, " ")
      netrulesize = Builtins.size(netlist)
      family = ""
      sockettype = ""

      if netrulesize == 1
        audit = {}
        rules = {}
      elsif netrulesize == 2
        family = Ops.get_string(netlist, 1, "")
        audit = Builtins.remove(audit, family)
        rules = Builtins.remove(rules, family)
      elsif netrulesize == 3
        family = Ops.get_string(netlist, 1, "")
        sockettype = Ops.get_string(netlist, 2, "")
        a = Ops.get_map(audit, family, {})
        r = Ops.get_map(rules, family, {})
        a = Builtins.remove(a, sockettype)
        r = Builtins.remove(r, sockettype)
        Ops.set(audit, family, a)
        Ops.set(rules, family, r) 
        # any fam =  netRules[family]:nil;
        # if ( is( fam, map ) ) {
        #     fam = remove( ((map) fam), sockettype );
        #     netRules[family] = fam;
        # } else {
        #     y2warning("deleteNetworkRule: deleting non-existing rule: " +
        #                rule);
        # }
      end
      { "audit" => audit, "rule" => rules }
    end

    def addNetworkRule(netRules, rule)
      netRules = deep_copy(netRules)
      audit = Ops.get_map(netRules, "audit", {})
      rules = Ops.get_map(netRules, "rule", {})
      netlist = Builtins.splitstring(rule, " ")
      netrulesize = Builtins.size(netlist)
      family = ""
      sockettype = ""

      if netrulesize == 1
        return { "audit" => { "all" => 1 }, "rule" => { "all" => 1 } }
      else
        if Builtins.haskey(audit, "all") && Builtins.haskey(rules, "all")
          audit = Builtins.remove(audit, "all")
          rules = Builtins.remove(rules, "all")
        end

        if netrulesize == 2
          family = Ops.get_string(netlist, 1, "")
          Ops.set(audit, family, 0)
          Ops.set(rules, family, 1)
        elsif netrulesize == 3
          family = Ops.get_string(netlist, 1, "")
          sockettype = Ops.get_string(netlist, 2, "")
          Ops.set(
            audit,
            family,
            Builtins.add(Ops.get_map(audit, family, {}), sockettype, 0)
          )
          Ops.set(
            rules,
            family,
            Builtins.add(Ops.get_map(rules, family, {}), sockettype, 1)
          )
        end 
        # any any_fam = netRules[family]:nil;
        # map fam = nil;
        # if ( is( any_fam, map ) )  {
        #    fam = (map) any_fam;
        # }
        # if ( fam == nil ) {
        #     fam = $[];
        # }
        # fam[sockettype] = "1";
        # netRules[family] = fam;
      end
      { "audit" => audit, "rule" => rules }
    end

    def editNetworkRule(netRules, old, new)
      netRules = deep_copy(netRules)
      netRules = deleteNetworkRule(netRules, old)
      netRules = addNetworkRule(netRules, new)
      deep_copy(netRules)
    end

    #
    # generateTableContents - generate the list that is used in the table to display the profile
    #

    def generateTableContents(paths, network, caps, includes, hats)
      paths = deep_copy(paths)
      network = deep_copy(network)
      caps = deep_copy(caps)
      includes = deep_copy(includes)
      hats = deep_copy(hats)
      newlist = []

      indx = 0

      Builtins.foreach(
        Convert.convert(hats, :from => "map", :to => "map <string, map>")
      ) do |hatname, hat|
        newlist = Builtins.add(
          newlist,
          Item(Id(indx), Ops.add("[+] ^", hatname), "")
        )
        indx = Ops.add(indx, 1)
      end

      Builtins.foreach(
        Convert.convert(
          includes,
          :from => "map",
          :to   => "map <string, integer>"
        )
      ) do |incname, incval|
        newlist = Builtins.add(
          newlist,
          Item(Id(indx), Ops.add("#include ", incname), "")
        )
        indx = Ops.add(indx, 1)
      end

      Builtins.foreach(
        Convert.convert(caps, :from => "map", :to => "map <string, map>")
      ) do |capname, capval|
        capdef = Ops.get(@capdefs, capname)
        newlist = Builtins.add(
          newlist,
          Item(Id(indx), Ops.get_string(capdef, "name", ""), "")
        )
        indx = Ops.add(indx, 1)
      end

      Builtins.foreach(
        Convert.convert(paths, :from => "map", :to => "map <string, map>")
      ) do |name, val|
        mode = Convert.to_string(
          SCR.Execute(
            path(".apparmor_profiles.mode_to_string"),
            Ops.get_integer(val, "mode", 0)
          )
        )
        newlist = Builtins.add(newlist, Item(Id(indx), name, mode))
        indx = Ops.add(indx, 1)
      end

      rules = Ops.get_map(network, "rule", {})
      Builtins.foreach(
        Convert.convert(rules, :from => "map", :to => "map <string, any>")
      ) do |family, any_fam|
        if Ops.is_map?(any_fam)
          Builtins.foreach(
            Convert.convert(any_fam, :from => "any", :to => "map <string, any>")
          ) do |socktype, any_type|
            newlist = Builtins.add(
              newlist,
              Item(
                Id(indx),
                Ops.add(Ops.add(Ops.add("network ", family), " "), socktype),
                ""
              )
            )
            indx = Ops.add(indx, 1)
          end
        else
          # Check for all network
          if family == "all"
            newlist = Builtins.add(newlist, Item(Id(indx), "network", ""))
            indx = Ops.add(indx, 1)
          else
            newlist = Builtins.add(
              newlist,
              Item(Id(indx), Ops.add("network ", family), "")
            )
            indx = Ops.add(indx, 1)
          end
        end
      end
      deep_copy(newlist)
    end


    def collectHats(profile, pathname)
      profile = deep_copy(profile)
      hats = {}
      Builtins.y2debug(Ops.add("collecting hats for ", pathname))
      if profile != nil
        Builtins.foreach(
          Convert.convert(profile, :from => "map", :to => "map <string, any>")
        ) do |resname, resource|
          if resname != pathname
            hat = Builtins.tomap(resource)
            if hat != nil
              Builtins.y2debug(Ops.add("HAT ", resname))
              hats = Builtins.add(hats, resname, resource)
            end
          end
        end
      end
      deep_copy(hats)
    end


    #
    # Prompts the user for a hatname
    # Side-Effect: sets Settings["CURRENT_HAT"]
    # returns true (hat entered)
    #         false (user aborted)
    #
    def newHatNamePopup(parentProfile, currentHats)
      currentHats = deep_copy(currentHats)
      intro = VBox(
        Top(
          VBox(
            VSpacing(1),
            Left(
              Label(
                Ops.add(
                  Ops.add(
                    _(
                      "Enter the name of the Hat that you would like \nto add to the profile\n"
                    ) + "  ",
                    parentProfile
                  ),
                  "."
                )
              )
            ),
            VSpacing(0.5),
            Left(TextEntry(Id(:hatname), _("&Hat name to add"), "")),
            VSpacing(Opt(:vstretch), 0.25)
          )
        ),
        HBox(
          HSpacing(Opt(:hstretch), 0.1),
          HCenter(PushButton(Id(:create), _("&Create Hat"))),
          HCenter(PushButton(Id(:abort), Label.AbortButton)),
          HSpacing(Opt(:hstretch), 0.1),
          VSpacing(1)
        )
      )

      UI.OpenDialog(intro)
      UI.SetFocus(Id(:hatname))
      while true
        input = Wizard.UserInput
        if input == :create
          hatname = Convert.to_string(UI.QueryWidget(Id(:hatname), :Value))
          # Check for no application entry in the dialog
          if hatname == ""
            Popup.Error(
              _(
                "You have not given a name for the hat you want to add.\n" +
                  "Please \n" +
                  "enter a hat name to create a new hat, or press Abort to cancel this wizard."
              )
            )
          elsif Builtins.haskey(currentHats, hatname)
            Popup.Error(
              _(
                "The profile already contains the provided hat name. Enter a different name or press Abort to cancel this wizard."
              )
            )
          else
            Ops.set(@Settings, "CURRENT_HAT", hatname)
            UI.CloseDialog
            return true
          end
        else
          UI.CloseDialog
          return false
        end
      end

      nil
    end

    def DisplayProfileForm(pathname, hat)
      profile_map = Ops.get_map(@Settings, "PROFILE_MAP", {})
      profile = Ops.get_map(profile_map, pathname, {})
      hats = {}
      hats = collectHats(profile_map, pathname) if !hat
      paths = Ops.get_map(profile, ["allow", "path"], {})
      caps = Ops.get_map(profile, ["allow", "capability"], {})
      includes = Ops.get_map(profile, "include", {})
      netdomain = Ops.get_map(profile, ["allow", "netdomain"], {})
      profilelist = generateTableContents(
        paths,
        netdomain,
        caps,
        includes,
        hats
      )


      # FIXME: format these texts better

      # help text
      help1 = _(
        "<p>View and modify the contents of an individual profile. For existing entries double click the permissions to access a modification dialog.</p>"
      )

      # help text
      help2 = _(
        "<p><b>Permission Definitions:</b><br><code> r - read <br> \n" +
          "w -write<br>l - link<br>m - mmap PROT_EXEC<br>k - file locking<br>\n" +
          "a - file append<br>x - execute<br> i - inherit<br> p - discrete profile<br>\n" +
          "P - discrete profile <br> (*clean exec)<br> u - unconstrained<br> \n" +
          "U -unconstrained<br> (*clean exec)</code></p>"
      )

      # help text
      help3 = _(
        "<p><b>Add Entry:</b><br>Select the type of resource to add from the drop down list.</p>"
      )

      # help text - part x1
      help4 = _(
        "<p><ul><li><b>File</b><br>Add a file entry to this profile.</li>"
      )
      # help text - part x2
      help5 = _(
        "<li><b>Directory</b><br>Add a directory entry to this profile.</li>"
      )
      # help text - part x3
      help6 = _(
        "<li><b>Capability</b><br>Add a capability entry to this profile.</li>"
      )
      # help text - part x4
      help7 = _(
        "<li><b>Include</b><br>Add an include entry to this profile. This option \nincludes the profile entry contents of another file in this profile at load time.</li>"
      )
      # help text - part x5
      help_net = _(
        "<li><b>Network Entry</b><br>Add a network rule entry to this profile. \n" +
          "This option will allow you to specify network access privileges for the profile. \n" +
          "You may specify a network address family and socket type.</li>"
      )
      # help text - part x6
      helpHat = _(
        "<li><b>Hat</b><br>Add a sub-profile for this profile, called a Hat. This\n" +
          "option is analogous to manually creating a new profile, which can be selected\n" +
          "during execution only in the context of being asked for by a <b>changehat\n" +
          "aware</b> application. \n" +
          "For more information on changehat, see <b>man changehat</b> on your system or the Novell AppArmor Administration Guide.</li>"
      )
      # help text - part x7
      helpEdit = _(
        "</ul></p><p><b>Edit Entry:</b><br>Edit the selected entry.</p>"
      )

      # help text
      help8 = _(
        "<p><b>Delete Entry:</b><br>Removes the selected entry from this profile.</p>"
      )

      # help text - part y1
      help9 = _(
        "<p><b>*Clean Exec</b><br>The Clean Exec option for the discrete profile \n" +
          "and unconstrained execute permissions provide added security by stripping the environment \n" +
          "that is inherited by the child program of specific variables. These variables are:"
      )
      # help text - part y2
      help10 = "<ul> <li>GCONV_PATH</li><li>GETCONF_DIR</li><li>HOSTALIASES</li><li>LD_AUDIT</li><li>LD_DEBUG</li><li>LD_DEBUG_OUTPUT</li><li>LD_DYNAMIC_WEAK</li><li>LD_LIBRARY_PATH</li><li>LD_ORIGIN_PATH</li><li>LD_PRELOAD</li><li>LD_PROFILE</li><li>LD_SHOW_AUXV</li><li>LD_USE_LOAD_BIAS</li><li>LOCALDOMAIN</li><li>LOCPATH</li><li>MALLOC_TRACE</li><li>NLSPATH</li><li>RESOLV_HOST_CONF</li><li>RES_OPTION</li><li>TMPDIR</li><li>TZDIR</li></ul></p>"


      listnum = 0
      itemList = [
        Item(Id(:file), _("&File")),
        Item(Id(:net), _("Network &Rule")),
        Item(Id(:dir), _("&Directory")),
        Item(Id(:cap), _("&Capability")),
        Item(Id(:include), _("&Include File"))
      ]


      mainLabel = ""

      if hat
        mainLabel = Ops.add(
          Ops.add(
            Ops.add(
              _("AppArmor profile "),
              Ops.get_string(@Settings, "CURRENT_PROFILE", "")
            ),
            "^"
          ),
          pathname
        )
      else
        itemList = Builtins.add(itemList, Item(Id(:hat), _("&Hat")))
        mainLabel = Ops.add(_("AppArmor profile for "), pathname)
      end
      # Define the widget contents
      # for the Wizard
      contents_main_profile_form = VBox(
        Label(mainLabel),
        HBox(
          VSpacing(10),
          Table(
            Id(:table),
            Opt(:notify, :immediate),
            Header(_("File Name"), _("Permissions")),
            profilelist
          )
        ),
        VSpacing(0.5),
        HBox(
          HSpacing(Opt(:hstretch), 0.1),
          HCenter(MenuButton(Id(:addMenu), _("Add Entry"), itemList)),
          HCenter(PushButton(Id(:edit), _("&Edit Entry"))),
          HCenter(PushButton(Id(:delete), _("&Delete Entry"))),
          HSpacing(Opt(:hstretch), 0.1),
          VSpacing(1)
        ),
        VSpacing(1)
      )
      help = ""
      formtitle = ""
      if hat
        help = Ops.add(
          Ops.add(
            Ops.add(
              Ops.add(
                Ops.add(
                  Ops.add(
                    Ops.add(
                      Ops.add(
                        Ops.add(Ops.add(Ops.add(help1, help2), help3), help4),
                        help5
                      ),
                      help6
                    ),
                    help7
                  ),
                  help_net
                ),
                help8
              ),
              helpEdit
            ),
            help9
          ),
          help10
        )
        formtitle = _("AppArmor Hat Dialog")
      else
        help = Ops.add(
          Ops.add(
            Ops.add(
              Ops.add(
                Ops.add(
                  Ops.add(
                    Ops.add(
                      Ops.add(
                        Ops.add(
                          Ops.add(Ops.add(Ops.add(help1, help2), help3), help4),
                          help5
                        ),
                        help6
                      ),
                      help7
                    ),
                    help_net
                  ),
                  helpHat
                ),
                helpEdit
              ),
              help8
            ),
            help9
          ),
          help10
        )
        formtitle = _("AppArmor Profile Dialog")
      end
      Wizard.SetContentsButtons(
        formtitle,
        contents_main_profile_form,
        help,
        Label.BackButton,
        _("&Done")
      )



      event = {}
      id = nil
      while true
        event = UI.WaitForEvent(@timeout_millisec)
        id = Ops.get(event, "ID") # We'll need this often - cache it
        itemselected = Convert.to_integer(
          UI.QueryWidget(Id(:table), :CurrentItem)
        )
        if id == :table && Ops.get(event, "EventReason") == "Activated" ||
            id == :edit
          # Widget activated in the table
          rule = Ops.get_string(
            Convert.to_term(
              UI.QueryWidget(Id(:table), term(:Item, itemselected))
            ),
            1,
            ""
          )
          findcap = Builtins.find(rule, "CAP_")
          findinc = Builtins.find(rule, "#include")
          findhat = Builtins.find(rule, "[+] ^")
          findnet = Builtins.find(rule, "network")
          oldrule = rule
          if findcap == 0
            caps = capabilityEntryPopup(caps, rule, pathname)
            Ops.set(profile, ["allow", "capability"], caps)
          elsif findinc == 0
            Popup.Error(
              _(
                "Include entries can not be edited. Select add or delete to manage Include entries."
              )
            )
            next
          elsif findhat == 0
            hatToEdit = Builtins.substring(rule, 5)
            Ops.set(@Settings, "CURRENT_HAT", hatToEdit)
            return :showhat
          elsif findnet == 0
            newrule = networkEntryPopup(rule)
            if newrule != "" && newrule != rule
              netdomain = editNetworkRule(netdomain, rule, newrule)
            end
            Ops.set(profile, ["allow", "netdomain"], netdomain)
          else
            perms = Ops.get_string(
              Convert.to_term(
                UI.QueryWidget(Id(:table), term(:Item, itemselected))
              ),
              2,
              ""
            )
            results = fileEntryPopup(rule, perms, pathname)
            newperms = 0
            newperms = Convert.to_integer(
              SCR.Execute(
                path(".apparmor_profiles.string_to_mode"),
                Ops.get_string(results, "PERM", "")
              )
            )
            rule = Ops.get_string(results, "FILE", "")
            if rule != ""
              paths = Builtins.remove(paths, oldrule) if rule != oldrule
              paths = Builtins.add(
                paths,
                rule,
                { "audit" => 0, "mode" => newperms }
              )
              Ops.set(profile, ["allow", "path"], paths)
            end
          end
          Ops.set(profile_map, pathname, profile)
          Ops.set(@Settings, "PROFILE_MAP", profile_map)
          profilelist2 = generateTableContents(
            paths,
            netdomain,
            caps,
            includes,
            hats
          )
          UI.ChangeWidget(Id(:table), :Items, profilelist2)
          UI.ChangeWidget(Id(:table), :CurrentItem, itemselected)
        elsif id == :delete
          rule = Ops.get_string(
            Convert.to_term(
              UI.QueryWidget(Id(:table), term(:Item, itemselected))
            ),
            1,
            ""
          )
          findcap = Builtins.find(rule, "CAP_")
          findinc = Builtins.find(rule, "#include")
          findhat = Builtins.find(rule, "[+] ^")
          findnet = Builtins.find(rule, "network")

          if findcap == 0
            capNameToDelete = Ops.get(@linnametolp, rule, "")
            caps = Builtins.remove(caps, capNameToDelete)
            Ops.set(profile, ["allow", "capability"], caps)
          elsif findinc == 0
            includeToRemove = Builtins.substring(rule, 9)
            includes = Builtins.remove(includes, includeToRemove)
            Ops.set(profile, "include", includes)
          elsif findhat == 0
            hatToRemove = Builtins.substring(rule, 5)
            hats = Builtins.remove(hats, hatToRemove)
            profile_map = Builtins.remove(profile_map, hatToRemove)
          elsif findnet == 0
            netdomain = deleteNetworkRule(netdomain, rule)
            Ops.set(profile, ["allow", "netdomain"], netdomain)
          else
            paths = Builtins.remove(paths, rule)
            Ops.set(profile, ["allow", "path"], paths)
          end
          Ops.set(profile_map, pathname, profile)
          Ops.set(@Settings, "PROFILE_MAP", profile_map)
          profilelist2 = generateTableContents(
            paths,
            netdomain,
            caps,
            includes,
            hats
          )
          UI.ChangeWidget(Id(:table), :Items, profilelist2)
          UI.ChangeWidget(
            Id(:table),
            :CurrentItem,
            Ops.subtract(itemselected == 0 ? 0 : itemselected, 1)
          )
        elsif id == :file || id == :dir
          addfname = ""
          addperms = 0
          newentry = nil
          if id == :dir
            newentry = dirEntryPopup("", "", pathname)
          else
            newentry = fileEntryPopup("", "", pathname)
          end
          next if newentry == nil
          addfname = Ops.get_string(newentry, "FILE", "")
          addperms = Convert.to_integer(
            SCR.Execute(
              path(".apparmor_profiles.string_to_mode"),
              Ops.get_string(newentry, "PERM", "")
            )
          )
          # Make sure that the entry doesn't already exist
          paths = Builtins.add(
            paths,
            addfname,
            { "audit" => 0, "mode" => addperms }
          )
          Ops.set(profile, ["allow", "path"], paths)
          Ops.set(profile_map, pathname, profile)
          Ops.set(@Settings, "PROFILE_MAP", profile_map)
          profilelist2 = generateTableContents(
            paths,
            netdomain,
            caps,
            includes,
            hats
          )
          UI.ChangeWidget(Id(:table), :Items, profilelist2)
          UI.ChangeWidget(Id(:table), :CurrentItem, itemselected)
        elsif id == :cap
          caps = capabilityEntryPopup(caps, "", pathname)
          Ops.set(profile, ["allow", "capability"], caps)
          Ops.set(profile_map, pathname, profile)
          Ops.set(@Settings, "PROFILE_MAP", profile_map)
          profilelist2 = generateTableContents(
            paths,
            netdomain,
            caps,
            includes,
            hats
          )
          UI.ChangeWidget(Id(:table), :Items, profilelist2)
        elsif id == :hat
          Popup.Error(_("Hats can not have embedded hats.")) if hat
          hatCreated = newHatNamePopup(pathname, hats)
          return :showhat if hatCreated == true
        elsif id == :include
          customIncludes = Convert.convert(
            SCR.Read(path(".apparmor"), "custom-includes"),
            :from => "any",
            :to   => "list <string>"
          )
          newInclude = UI.AskForExistingFile(
            "/etc/apparmor.d/abstractions",
            "",
            _("Select File to Include")
          )
          next if newInclude == nil || newInclude == ""
          validIncludes = [
            "/etc/apparmor.d/abstractions",
            "/etc/apparmor.d/program-chunks",
            "/etc/apparmor.d/tunables"
          ]
          Builtins.foreach(customIncludes) do |incPath|
            validIncludes = Builtins.add(
              validIncludes,
              Ops.add("/etc/apparmor.d/", incPath)
            )
          end

          result = 0
          includePathOK = false
          Builtins.foreach(validIncludes) do |pathToCheck|
            result = Builtins.find(newInclude, pathToCheck)
            includePathOK = true if result != -1
          end

          if !includePathOK
            pathListMsg = ""
            Builtins.foreach(validIncludes) do |pathItem|
              pathListMsg = Ops.add(Ops.add(pathListMsg, "\n  "), pathItem)
            end
            Popup.Error(
              Ops.add(
                _(
                  "Invalid #include file. Include files must be located in one of these directories: \n"
                ),
                pathListMsg
              )
            )
          else
            includeName = Builtins.substring(newInclude, 16)
            includes = Builtins.add(includes, includeName, 1)
            Ops.set(profile, "include", includes)
            Ops.set(profile_map, pathname, profile)
            Ops.set(@Settings, "PROFILE_MAP", profile_map)
            profilelist2 = generateTableContents(
              paths,
              netdomain,
              caps,
              includes,
              hats
            )
            UI.ChangeWidget(Id(:table), :Items, profilelist2)
          end
        elsif id == :net
          newrule = networkEntryPopup("")
          if newrule != ""
            netdomain = addNetworkRule(netdomain, newrule)
            Ops.set(profile, ["allow", "netdomain"], netdomain)
            Ops.set(profile_map, pathname, profile)
            Ops.set(@Settings, "PROFILE_MAP", profile_map)
            profilelist2 = generateTableContents(
              paths,
              netdomain,
              caps,
              includes,
              hats
            )
            UI.ChangeWidget(Id(:table), :Items, profilelist2)
          end
        elsif id == :abort || id == :cancel
          break
        elsif id == :back
          break
        elsif id == :next
          if !hat
            if Popup.YesNoHeadline(
                _("Save changes to the profile"),
                _(
                  "Save the changes to this profile? \n(Note: after saving, AppArmor profiles will be reloaded.)\n"
                )
              )
              argmap = {
                "PROFILE_HASH" => Ops.get_map(@Settings, "PROFILE_MAP", {}),
                "PROFILE_NAME" => pathname
              }
              result = SCR.Write(path(".apparmor_profiles"), argmap)
              result2 = SCR.Execute(path(".target.bash"), "/sbin/apparmor_parser -r /etc/apparmor.d")
            end
          else
            if !Builtins.haskey(
                hats,
                Ops.get_string(@Settings, "CURRENT_HAT", "")
              )
              Ops.set(profile, ["allow", "path"], paths)
              Ops.set(profile, ["allow", "capability"], caps)
              Ops.set(profile, "include", includes)
              Ops.set(profile_map, pathname, profile)
              Ops.set(@Settings, "PROFILE_MAP", profile_map)
            end
            return :next
          end
          break
        else
          Builtins.y2error("Unexpected return code: %1", id)
          next
        end
      end
      Convert.to_symbol(id)
    end


    #
    # Select a profile to edit and populate
    # Settings["CURRENT_PROFILE"]: profile name
    # Settings["PROFILE_MAP"]: map containing the profile
    #
    def SelectProfileForm(profiles, formhelp, formtitle, iconname)
      profiles = deep_copy(profiles)
      # TODO switch to variable in a module
      # TODO plain reread does not work here
      SCR.UnmountAgent(path(".apparmor_profiles"))
      profiles = Convert.to_map(SCR.Read(path(".apparmor_profiles"), "all"))
      profilelisting = []
      indx = 0
      Builtins.foreach(
        Convert.convert(profiles, :from => "map", :to => "map <string, any>")
      ) do |p, ignore|
        profilelisting = Builtins.add(profilelisting, Item(Id(p), p))
        indx = Ops.add(indx, 1)
      end

      contents_select_profile_form = VBox(
        VSpacing(2),
        SelectionBox(
          Id(:profilelist),
          Opt(:notify),
          _("Profile Name"),
          profilelisting
        ),
        VSpacing(3),
        HBox(
          PushButton(Id(:edit), Label.EditButton),
          PushButton(Id(:delete), Label.DeleteButton),
          HStretch()
        )
      )

      #
      # Create the Dialog Window and parse user input
      #
      Wizard.CreateDialog
      Wizard.SetContents(
        formtitle,
        contents_select_profile_form,
        formhelp,
        false,
        true
      )
      Wizard.SetTitleIcon(iconname)

      event = {}
      id = nil
      profilename = ""
      while true
        event = UI.WaitForEvent(@timeout_millisec)
        id = Ops.get(event, "ID") # We'll need this often - cache it
        profilename = Builtins.tostring(
          UI.QueryWidget(Id(:profilelist), :CurrentItem)
        )
        if id == :edit
          if profilename != nil && profilename != ""
            break
          else
            Popup.Error(_("You must select a profile to edit."))
            next
          end # TODO ELSE POPUP NO ENTRY SELECTED ERROR
        elsif id == :delete
          # Translators: %1 is the name of the profile.
          popup_msg = Builtins.sformat(_("Are you sure you want to delete the profile \"%1\"?"), profilename )
          popup_msg += "\n" + _("After this operation the AppArmor module will reload the profile set.")
          if Popup.YesNoHeadline(_("Delete profile confirmation"), popup_msg)
            Builtins.y2milestone("Deleted %1", profilename)
            result = SCR.Write(path(".apparmor_profiles.delete"), profilename)
            result2 = SCR.Execute(path(".target.bash"), "/sbin/apparmor_parser -r /etc/apparmor.d")
          end
          id = :reread
          break
        end
        if id == :abort || id == :cancel
          break
        # This module break common work-flow that changes are commited at the end, so react same for break and also for next
        elsif id == :back || id == :next
          break
        else
          Builtins.y2error("Unexpected return code: %1", id)
          next
        end
      end
      if id == :edit
        Ops.set(@Settings, "CURRENT_PROFILE", profilename)
        Ops.set(@Settings, "PROFILE_MAP", Ops.get(profiles, profilename))
      end
      UI.CloseDialog
      Convert.to_symbol(id)
    end
  end
end
