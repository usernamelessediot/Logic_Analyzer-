# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_ENTRIES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_INPUTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TIMER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TRIG_COND_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to update DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_WIDTH { PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to validate DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.NUM_ENTRIES { PARAM_VALUE.NUM_ENTRIES } {
	# Procedure called to update NUM_ENTRIES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_ENTRIES { PARAM_VALUE.NUM_ENTRIES } {
	# Procedure called to validate NUM_ENTRIES
	return true
}

proc update_PARAM_VALUE.NUM_INPUTS { PARAM_VALUE.NUM_INPUTS } {
	# Procedure called to update NUM_INPUTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_INPUTS { PARAM_VALUE.NUM_INPUTS } {
	# Procedure called to validate NUM_INPUTS
	return true
}

proc update_PARAM_VALUE.TIMER_WIDTH { PARAM_VALUE.TIMER_WIDTH } {
	# Procedure called to update TIMER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TIMER_WIDTH { PARAM_VALUE.TIMER_WIDTH } {
	# Procedure called to validate TIMER_WIDTH
	return true
}

proc update_PARAM_VALUE.TRIG_COND_WIDTH { PARAM_VALUE.TRIG_COND_WIDTH } {
	# Procedure called to update TRIG_COND_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TRIG_COND_WIDTH { PARAM_VALUE.TRIG_COND_WIDTH } {
	# Procedure called to validate TRIG_COND_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.DATA_WIDTH { MODELPARAM_VALUE.DATA_WIDTH PARAM_VALUE.DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_WIDTH}] ${MODELPARAM_VALUE.DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.NUM_ENTRIES { MODELPARAM_VALUE.NUM_ENTRIES PARAM_VALUE.NUM_ENTRIES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_ENTRIES}] ${MODELPARAM_VALUE.NUM_ENTRIES}
}

proc update_MODELPARAM_VALUE.TRIG_COND_WIDTH { MODELPARAM_VALUE.TRIG_COND_WIDTH PARAM_VALUE.TRIG_COND_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TRIG_COND_WIDTH}] ${MODELPARAM_VALUE.TRIG_COND_WIDTH}
}

proc update_MODELPARAM_VALUE.TIMER_WIDTH { MODELPARAM_VALUE.TIMER_WIDTH PARAM_VALUE.TIMER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TIMER_WIDTH}] ${MODELPARAM_VALUE.TIMER_WIDTH}
}

proc update_MODELPARAM_VALUE.NUM_INPUTS { MODELPARAM_VALUE.NUM_INPUTS PARAM_VALUE.NUM_INPUTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_INPUTS}] ${MODELPARAM_VALUE.NUM_INPUTS}
}

