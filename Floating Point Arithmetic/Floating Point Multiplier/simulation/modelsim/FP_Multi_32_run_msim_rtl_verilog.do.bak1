transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/IIT\ BOMBAY/M.Tech\ Projects/Floating\ Point\ Arithmetic/Floating\ Point\ Multiplier {D:/IIT BOMBAY/M.Tech Projects/Floating Point Arithmetic/Floating Point Multiplier/FP_Multi_32.v}

vlog -vlog01compat -work work +incdir+D:/IIT\ BOMBAY/M.Tech\ Projects/Floating\ Point\ Arithmetic/Floating\ Point\ Multiplier {D:/IIT BOMBAY/M.Tech Projects/Floating Point Arithmetic/Floating Point Multiplier/TB_FP_multi.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  TB_FP_multi

add wave *
view structure
view signals
run -all
