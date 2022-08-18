transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/IIT\ BOMBAY/M.Tech\ Projects/Floating\ Point\ Arithmetic/Floating\ Point\ Adder {D:/IIT BOMBAY/M.Tech Projects/Floating Point Arithmetic/Floating Point Adder/FP_Adder_32.v}

vlog -vlog01compat -work work +incdir+D:/IIT\ BOMBAY/M.Tech\ Projects/Floating\ Point\ Arithmetic/Floating\ Point\ Adder {D:/IIT BOMBAY/M.Tech Projects/Floating Point Arithmetic/Floating Point Adder/Tb_FP_adder.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  Tb_FP_adder

add wave *
view structure
view signals
run -all
