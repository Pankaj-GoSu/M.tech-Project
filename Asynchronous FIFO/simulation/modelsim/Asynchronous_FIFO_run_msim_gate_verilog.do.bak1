transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {Asynchronous_FIFO.vo}

vlog -vlog01compat -work work +incdir+D:/IIT\ BOMBAY/M.Tech\ Projects/Asynchronous\ FIFO {D:/IIT BOMBAY/M.Tech Projects/Asynchronous FIFO/Tb_Asynchronous_FIFO.v}

vsim -t 1ps -L altera_ver -L altera_lnsim_ver -L cyclonev_ver -L lpm_ver -L sgate_ver -L cyclonev_hssi_ver -L altera_mf_ver -L cyclonev_pcie_hip_ver -L gate_work -L work -voptargs="+acc"  Tb_Asynchronous_FIFO

add wave *
view structure
view signals
run -all
