if { ![info exists env(VIVADO_DESIGN_NAME)] } {
    puts "Please set the environment variable VIVADO_DESIGN_NAME before running the script"
    return
}
set design_name $::env(VIVADO_DESIGN_NAME)
puts "Using design name: ${design_name}"

if { ![info exists env(VIVADO_TOP_NAME)] } {
    puts "No top design defined. Using the default top name ${design_name}_wrapper"
    set top_name ${design_name}_wrapper
} else {
  set top_name $::env(VIVADO_TOP_NAME)
  puts "Using top name: ${top_name}"
}

# Generate bitstream
open_project ./vivado/${design_name}/${design_name}.xpr
update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

# If the src dir has not apps to be compiled, then this is a hardware only project.
# no need to export the hardware to SDK and to run SDK
set app_list [glob -nocomplain -dir src "*"]
if {[llength $file_list] != 0} {
    # exporting hw design to SDK
    file mkdir ./vivado/${design_name}/${design_name}.sdk
    file copy -force ./vivado/${design_name}/${design_name}.runs/impl_1/${top_name}.sysdef ./vivado/${design_name}/${design_name}.sdk/${design_name}.hdf
    puts "========================"
    puts "Hardware exported to SDK"
    puts "========================"
} else {
    puts "==================================="
    puts "There is no software to be compiled"
    puts "==================================="
}

close_design
