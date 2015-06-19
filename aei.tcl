#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# Automatic Eggdrop Installer v.51
#
#   feel free to modify this and/or
#   submit modifications/new ideas/bugs to
#   nemisis@intercarve.net
#
#   Read the README file for information how
#   the parsing engine works exactly.
#   
#   Oh yes, do not forget to change the variable named '::aei::eggdropname'
#   to reflect the proper path.
#
#
# RCS: @(#) $Id: aei.tcl,v .5 2002/04/28 17:27:24 bliss Exp $
#
# (c) 2002 Matt Saladna/Apis Networks
# All Rights Reserved
#
# changelog:
#   v.1 - initial release
#   v.5 - new release, rewrote internal engine
#   v.51 - fixed a minor bug

namespace eval ::aei {
    variable ::aei::eggdropname
    set ::aei::eggdropname "/tmp/eggdrop1.6.8.tar.gz" ; # include full path
    
    proc init {} {
        puts stdout "Welcome to the Automatic Eggdrop Installer!"
        puts stdout "============================================"
        puts stdout "|         Current Eggdrop Version          |"
        puts stdout "|              [file tail [file rootname [file rootname $::aei::eggdropname]]]                |"
        puts stdout "|__________________________________________|"
        puts stdout "\n\n"
        catch [file delete [file join ~ [file tail [file rootname [file rootname $::aei::eggdropname]]]]]
        puts stdout "One minute while the source is decompressed."
        catch {cd ~/}
        if [catch {exec tar -xvzf $::aei::eggdropname} ::aei::error] {
            puts stderr "Unable to decompress ${::aei::eggdropname}!"
            puts stderr "Fatal error, cannot continue! Consult your administrator."
            puts stderr "Error generated: $::aei::error"
            exit 1
        }
        puts stdout "Done."
        catch {cd [file join ~ [file tail [file rootname [file rootname $::aei::eggdropname]]]]}
        set ::aei::input ""
        while {![regexp -nocase {6|exit} $::aei::input]} {
            puts stdout "Menu: "
            puts stdout "========================================================"
            puts stdout [format "%-30s %-23s %-10s" "1) Install" "2) Read readme" "|"]
            puts stdout [format "%-30s %-23s %-10s" "3) Read features" "4) Read news" "|"]
            puts stdout [format "%-30s %-23s %-10s" "5) Make new configuration" "6) Exit" "|"]
            puts stdout "========================================================"
            set ::aei::input [string trim [gets stdin]]
            switch -regexp -- $::aei::input {
                {1|[Ii][Nn][Ss][Tt][Aa][Ll][Ll]} \
                    {
                        set ::aei::sock  [open "aeiinstall.log" w 0600]
                        if [catch {cd [file join ~ [file tail [file rootname [file rootname $::aei::eggdropname]]]]}] {
                            puts stderr "Fatal error: Cannot change directory to eggdrop!"
                            exit 1
                        }
                        # make clean
                        puts stdout "executing make clean (may affect you)"
                        catch {exec make clean}
                        # ./configure handling
                        puts stdout "executing ./configure"
                        if [catch {exec ./configure} ::aei::error] {
                            foreach ::aei::tmpline [split $::aei::error \n] {
                                lappend ::aei::tmplist $::aei::tmpline
                            }
                            unset ::aei::tmpline
                            if {[lsearch $::aei::tmplist [list "./config.status: /misc/modconfig: No such file or directory"]] != -1} {
                                puts stderr "Error while executing ./configure, aborting."
                                puts stderr "Error message: $::aei::error"
                                exit 1
                            }
                            unset ::aei::tmplist
                        }
                        puts $::aei::sock $::aei::error     
                       # make config handling
                        puts stdout "executing make config"
                        if [catch {exec make config} ::aei::error] {
                            puts stderr "Error while executing make config, aborting."
                            puts stderr "Error message: $::aei::error"
                            exit 1
                        }              
                        puts $::aei::sock $::aei::error  
                        # make handling
                        puts stdout "executing make now.. this will take some time, go make a milk shake."
                        if [catch {exec make} ::aei::error] {
                            puts stderr "Error while executing make, aborting."
                            puts stderr "Error message: $::aei::error"
                            exit 1
                        }                
                        puts $::aei::sock $::aei::error     
                        # make install handling
                        puts stdout "executing make install"
                        if [catch {exec make install} ::aei::error] {
                            puts stderr "Error while executing make install, aborting."
                            puts stderr "Error message: $::aei::error"
                            exit 1
                        }
                        puts $::aei::sock $::aei::error
                        catch {close $::aei::sock}
                        cd ..
                        puts stdout "log file from installation is located in aeiinstall.log"
                        puts stdout "finished compiling eggdrop, location is now in [file join [pwd] eggdrop]"                     
                        ::aei::fileconfigure [file join  [pwd] eggdrop]
                        break
                    }
                {2|[Rr][eE][aA][dD][:space:]?[rR][eE][aA][dD][mM][eE]} \
                    {
                        if {![catch {set ::aei::sock [open [file join [pwd] [string range [file tail $::aei::eggdropname] 0 \
                            [expr {[string length [file tail $::aei::eggdropname]] - 8}]] README] r 0600]} error]} {
                                set ::aei::i 0
                                while {[gets $::aei::sock ::aei::line] > -1} {
                                    if {[regexp {^[:space:]*$} $::aei::line]} { continue }
                                    puts stdout $::aei::line
                                    gets stdin
                                }
                        catch {close $::aei::sock}
                        }
                    }
                {3|[Rr][eE][aA][dD][:space:]?[fF][eE][aA][tT][uU][rR][eE][sS]} \
                    {
                        if {![catch {set ::aei::sock [open [file join [pwd] [string range [file tail $::aei::eggdropname] 0 \
                           [expr {[string length [file tail $::aei::eggdropname]] - 8}]] FEATURES] r 0600]}]} {
                                while {[gets $::aei::sock ::aei::line] > -1} {
                                    puts stdout $::aei::line
                                    gets stdin
                                }
                        catch {close $::aei::sock}
                        }
                    } 
                {4|[Rr][eE][aA][dD][:space:]?[nN][eE][wW][sS]} \
                    {
                        if {![catch {set ::aei::sock [open [file join [pwd] [string range [file tail $::aei::eggdropname] 0 \
                           [expr {[string length [file tail $::aei::eggdropname]] - 8}]] NEWS] r 0600]}]} {
                                while {[gets $::aei::sock ::aei::line] > -1} {
                                    puts stdout $::aei::line
                                    gets stdin
                                }
                        catch {close $::aei::sock}                        
                        }            
                    }
                {5|[Mm][Aa][Kk][Ee][:space:]?[nN][eE][wW][:space:]?[Cc][oO][nN][fF][iI][gG]} \
                  {
                        cd ~
                        if {![file exists eggdrop]} {
                            puts stderr "eggdrop directory does not exist, cannot continue, please install it."
                            break
                        }
                        ::aei::fileconfigure [file join  [pwd] eggdrop]
                  }
            }       
        }
    }
    
    # core logic of the program, which configures the configuration
    # file. I hold no responsiblities for vagabond namespace
    # variables.
    proc fileconfigure {path} {
        if [catch {cd $path} error] {
            puts stderr "Unable to change into $path, error: $error was raised."
            exit 1
        }
        puts stdout "Looking for pre-defined configuration directives..."
        if [catch {set matches [glob -directory [file dirname $::aei::eggdropname] -- *.aei]} error] {
            puts stdout "No templates found; AEI cannot do anything."
            exit 1
        }
        set i 0
        foreach match $matches {
            if ![catch {set sock [open $match "r"]}] {
                while {[gets $sock line] > -1} {
                    if [regexp {^\s*([[:alnum:]\s]+)$} $line tmptitle] {
                        lappend titles $tmptitle
                        lappend srcs $match
                        incr i
                        break
                    }
                    if [regexp {^\s*pd:$} $line] { break }
                }
                close $sock
            }
        }
        if {$i == 0} {
            puts stderr "No templates found; AEI cannot do anything."
            exit 1
        }
        set i 1
        puts stdout "The following templates were found: "
        foreach title $titles {
            puts stdout "$i) $title"
            incr i
        }
        puts stdout "Please select the number of the template you wish to use"
        set i ""
        while {[string equal [string trim $i] ""]} {
            set i [gets stdin]
        }
        puts stdout "[lindex $titles [expr {$i - 1}]] was selected."
        if [catch {set sock [open [lindex $srcs [expr {$i - 1}]]]}] {
            puts stderr "Cannot open file, exiting."
            exit 1
        }
        puts stdout "Please enter a configuration file name to use: "
        set filename [file rootname [file tail [gets stdin]]]
        set sock2 [open "$filename.conf" "w"]
        puts $sock2 "#![file join [pwd] eggdrop]"
        set activewriting 0 ; set passivewriting 0
        interp create help
        # a quick note here:
        # activewriting is defined by no user-interaction
        # required, where-as passive writing first prompts the user
        # for a value.
        # activewriting is denoted by pd: beginning
        # passivewriting is denoted by ud:
        # think of the layout as a private/public class layout in C++
        while {[gets $sock line] > -1} {
            set line [string trim $line]
            if {[regexp {^\s*//.*$} $line]} { continue }
            if {[regexp {^\s*pd:$} $line]} {
                if {$passivewriting} { set passivewriting 0 }
                set activewriting 1
            } elseif {[regexp {^\s*ud:$} $line]} {
                if {$activewriting} { set activewriting 0 }
                set passivewriting 1
            }
            if {[regexp -nocase {\s*TITLE:(.+)} $line {} title]} {
                puts stdout [format "%-10s %-23s %-10s" "" $title ""]
                puts stdout [format "%-10s %-23s %-10s" "" "=====================" ""]
            }
            if {$activewriting && ![regexp -nocase {^\s*pd:$} $line]} {
                puts $sock2 $line
            } elseif {$passivewriting} {
                if {[regexp {\s*#\s*(.+)} $line help]} {
                    interp eval help [list lappend helplines $help]
                } elseif {[regexp {\s*(.*),(.*),(.*)} $line {} directive name value]} {
                    set directive [string trim $directive]
                    set name [string trim $name]
                    set value [string trim $value]
                    set input ""                    
                    while {[string equal "" $input] || [string equal ":help" $input]} {
                        if {[string equal "?" $value]} {
                            puts stdout "Enter a value for \"$directive $name\" \[use :help for information\]"
                            set input [string trim [gets stdin]]    
                            if {[string equal -nocase ":help" $input]} {
                                interp eval help {
                                    foreach line $helplines {
                                        puts stdout "\t[string trimleft $line "# "]"
                                    }
                                }
                            } elseif {![string equal "" $input]} {
                                puts $sock2 "$directive $name \"$input\""
                            }
                        } elseif {[string equal "-" $value]} {
                            puts stdout "Enter 1 or 0 (yes, no respectively) for \"$directive $name\" \[use :help for information\]"
                            set input [string trim [gets stdin]]    
                            if {[string equal -nocase ":help" $input]} {
                                interp eval help {
                                    foreach line $helplines {
                                        puts stdout "\t[string trimleft $line "# "]"
                                    }
                                }
                            } elseif {[string equal "1" $input]} {
                                puts $sock2 "$directive $name"
                            }
                        } 
                    }
                    interp eval help {set helplines ""} ; # clean-up interpreter                
                }
            }
        }
        interp delete help
        catch {close $sock2}
        catch {close $sock}
        puts stdout "Setup is complete!"
        puts stdout "Your configuration may be found in [file join [pwd] $filename.conf]"
        if {![catch {exec chmod u+x $filename.conf}]} {
            set type 1
            puts stdout "Eggdrop can be executed by typing ./$filename.conf -m"
        } else {
            puts stdout "Eggdrop can be executed by typing ./eggdrop $filename.conf -m"
            set type 0
        }
        set input ""
        while {[string equal $input ""]} {
            puts stdout "Would you like to run eggdrop now? \[yes/no\]"
            set input [string trim [gets stdin]]
        }
        set type 0
        if {[regexp -nocase {Yes|Y} $input]} {
            if [catch {cd [file join ~ eggdrop]}] {
                puts stderr "Unable to load eggdrop."
                exit 1
            } else {
                if {$type} {
                    puts stdout [exec [file join ~ eggdrop $filename.conf]]
                    puts stdout "[file join ~ [list eggdrop $filename.conf]]"
                } else {
                    puts stdout [exec [file join ~ eggdrop eggdrop] $filename.conf]
                }
            }
        }    
        puts stdout "\0\0"        
        puts stdout "2002 (c) Matt Saladna/msaladna@intercarve.net"
        puts stdout "Drop me a note if you find a bug or want more features."
        exit 0
    }
}
if {[info tclversion] <= 8.0} {
    puts stderr "Tcl version newer than 8.0 is required to correctly interpret the engine."
    puts stderr "It will _not_ run on anything earlier due to differences of regular expression handling."
    exit 1
}
::aei::init
