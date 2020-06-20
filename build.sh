#export VIVADO=/opt/Xilinx/Vivado/2018.2/bin/vivado
export VIVADO=/home/lsa/xilinx/2018.2/Vivado/2018.2/bin/vivado
export VIVADO_DESIGN_NAME=hermes_test_ip

if [ -f $VIVADO ]; then
  echo "###################################"
  echo "### Creating the Vivado Project ###"
  echo "###################################"
  $VIVADO -mode batch -source build.tcl
  echo "#########################"
  echo "### Writing bitstream ###"
  echo "#########################"
  $VIVADO -mode batch -source build_bitstream_export_sdk.tcl
  # check whether there is any software to be compiled, i.e., if there is any dir inside src/
  list_dirs=`ls -d ./src/*/`
  # build a bash list 
  has_software=($list_dirs)
  # check if len(list) > 0
  if [ "${#has_software[@]}" -gt 0 ]; 
  then
    echo "#########################"
    echo "### Compiling w SDK  ###"
    echo "#########################"
    xsct sdk.tcl
    echo "####################################"
    echo "### End of software compilation  ###"
    echo "####################################"
    echo "execute the following command to launch SDK GUI"
    echo "xsdk -workspace ./vivado/${VIVADO_DESIGN_NAME}/${VIVADO_DESIGN_NAME}.sdk/ -hwspec ./vivado/${VIVADO_DESIGN_NAME}/${VIVADO_DESIGN_NAME}.sdk/${VIVADO_DESIGN_NAME}_wrapper.hdf"
  fi;
elif [ -f ~/.bash_aliases ]; then
  echo ""
  echo "###############################"
  echo "### Failed to locate Vivado ###"
  echo "###############################"
  echo ""
  echo "This script file 'build.sh' did not find Vivado installed in:"
  echo ""
  echo "    $VIVADO"
  echo ""
  echo "Fix the problem by doing one of the following:"
  echo ""
  echo " 1. If you do not have this version of Vivado installed,"
  echo "    please install it or download the project sources from"
  echo "    a commit of the Git repository that was intended for"
  echo "    your version of Vivado."
  echo ""
  echo " 2. If Vivado is installed in a different location on your"
  echo "    PC, please modify the first line of this batch file "
  echo "    to specify the correct location."
  echo ""
fi
