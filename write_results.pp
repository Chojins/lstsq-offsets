{**********************************************************************
* PART PROGRAM:	write results.pp
*
* DESCRIPTION:	Save results from python lstsq machine offsets notebook
*
* COMMENTS:		
***********************************************************************}

{********************************************************
* Subroutine  :	I N I T _ L O C A L _ V A R
* Description :	Initialises the local variables

*********************************************************}
sub init_local_var

    logfile = "p:/tg7/misc/arbor_probing_Log.txt"
    
	timestamp = strdate() { strftime wrapper, defaults to "%c", so "%Y.%m.%d %H:%M:%S" etc }

	OPEN ( &outdata, logfile, APPEND ) 
	WRITE ( outdata, " Machine Offsets Write Results =================== \n %s \n", timestamp)
	close (outdata)

    {values obtaind from notebook}
    spindle_centerline_offset = ipf100
    y_home_offset = ipf101
    z_home_offset = ipf102
    c_home_offset = ipf103

    {read the current offset values}
	dba_get_float_parm(&spindle_centerline_offset_current, "spindle_cntr_line_off", "spindle_cntr_line_off")
	spindle_centerline_offset_current = unitcv(spindle_centerline_offset_current)

	dba_get_float_parm(&y_home_offset_current, "2.home_position", "2.home_position")
	y_home_offset_current = unitcv(y_home_offset_current)

	dba_get_float_parm(&z_home_offset_current, "3.home_position", "3.home_position")
	z_home_offset_current = unitcv(z_home_offset_current)

    dba_get_float_parm(&c_home_offset_current, "5.home_position", "5.home_position")

    {log Result }
    OPEN ( &outdata, logfile, APPEND ) 
    write(outdata, "\t\t\t\t\t\tCurrent\t\tNew Value\tChange\n")
    write(outdata, "spindle_cntr_line_off\t:\t%.3f\t\t%.3f\t\t%.3f\n",spindle_centerline_offset_current, spindle_centerline_offset, (spindle_centerline_offset_current - spindle_centerline_offset))
    write(outdata, "y_home_offset\t\t\t:\t%.3f\t\t%.3f\t\t%.3f\n",y_home_offset_current, y_home_offset, (y_home_offset_current - y_home_offset))
    write(outdata, "z_home_offset\t\t\t:\t%.3f\t\t%.3f\t\t%.3f\n", z_home_offset_current, z_home_offset, (z_home_offset_current - z_home_offset))
    write(outdata, "c_home_offset\t\t\t:\t%.3f\t\t%.3f\t\t%.3f\t(deg)\n", c_home_offset_current, c_home_offset, (c_home_offset_current - c_home_offset))
    close (outdata)

subend	{ init_local_var }

{********************************************************
* Subroutine  :	R E S E T _ A C K _ L A T C H
* Description :	reset latch for user to press ACK
*********************************************************}
sub reset_ack_latch

n10
	%GPB_ACK_LATCH_RESET = on	{ set plc bit to reset ACK, %GPB_ACK_LATCH}
	sync
	waitplc(1)					{ wait for 1 complete plc scan to reset ACK }
	if %GPB_ACK_LATCH then		{ if ACK latch still set (button press or stuck) then }
		dwell x0.05				{ wait until it is reset }
		sync
		goto n10		
	ifend
	%GPB_ACK_LATCH_RESET = off	{ set plc bit to reset ACK, %GPB_ACK_LATCH}

subend	{ reset_ack_latch }

{********************************************************
* Subroutine  :	W A I T _ F O R _A C K
* Description :	keep looping until ACK is pressed.  
*********************************************************}
sub wait_for_ack

	{******* wait for ACK to be pressed *******}
n40
	if !(%GPB_ACK_LATCH) then	{ if ACK latch still set (button press or stuck) then }
		dwell x0.05				{ wait until it is reset }
		sync
		goto n40		
	ifend
	sync

subend { wait_for_ack }

{************************
*** M A I N   B O D Y ***
*************************}
calls "init_local_var"


    
calls "reset_ack_latch"
wclose
write("Review the changes below: \n")
write("\t\t\t\tCurrent\t\tNew Value\tChange\n")
write("spindle_cntr_line_off\t:\t%.3f\t\t%.3f\t\t%.3f\n",spindle_centerline_offset_current, spindle_centerline_offset, (spindle_centerline_offset_current - spindle_centerline_offset))
write("y_home_offset\t\t:\t%.3f\t\t%.3f\t\t%.3f\n",y_home_offset_current, y_home_offset, (y_home_offset_current - y_home_offset))
write("z_home_offset\t\t:\t%.3f\t\t%.3f\t\t%.3f\n", z_home_offset_current, z_home_offset, (z_home_offset_current - z_home_offset))
write("c_home_offset\t\t:\t%.3f\t\t%.3f\t\t%.3f\t(deg)\n", c_home_offset_current, c_home_offset, (c_home_offset_current - c_home_offset))
write("\n\nPress <ACK> to save the new offset data")
calls "wait_for_ack"
wclose

{save the data to p_user}
dba_put_float_parm(DBA_USER, "spindle_cntr_line_off", spindle_centerline_offset / unitcv(1.0))
dba_put_float_parm(DBA_USER, "2.home_position", y_home_offset / unitcv(1.0))
dba_put_float_parm(DBA_USER, "3.home_position", z_home_offset / unitcv(1.0))
dba_put_float_parm(DBA_USER, "5.home_position", c_home_offset / unitcv(1.0))

return

{ END OF FILE }
