
{********************************************************
* Subroutine  :	I N I T _ L O C A L _ V A R
* Description :	Initialises the local variables
*				Database parameters that are used throughout
*				the cycle are also initialised and retrieved.
*********************************************************}
sub init_local_var
	logfile = "p:/tg7/misc/spindle_probing_Log.txt"
    datafile = "P:/TG7/misc/spindle_probing_data.txt"

	timestamp = strdate() { strftime wrapper, defaults to "%c", so "%Y.%m.%d %H:%M:%S" etc }

	OPEN ( &outdata, logfile, APPEND ) 
	WRITE ( outdata, " Machine Offsets Spindle Face Probing =================== \n %s \n", timestamp)
	close (outdata)

	dmy = dba_get_string_parm(&cyc_path,"tg.cyc_dir","dirs.dir")	\

	{ Home directory }
	dmy = dba_get_string_parm(&tga_home,"tga.home_dir","dirs.dir") 	\
	teach_home = tga_home+"/tcg/ppsys/ldm/rbt/auto_teach"			\
	
	{ grinder x home position }	
	dmy = dba_get_float_parm(&mx_home_preset, "1.home_position", "Joint.Hpp") \
	mx_home_preset = unitcv(mx_home_preset) \

	{ grinder y home position }	
	dmy = dba_get_float_parm(&my_home_preset, "2.home_position", "Joint.Hpp") \	
	my_home_preset = unitcv(my_home_preset) \

	{ grinder z home position }	
	dmy = dba_get_float_parm(&mz_home_preset, "3.home_position", "Joint.Hpp") \	
	mz_home_preset = unitcv(mz_home_preset) \

	{ grinder c home position }	
	dmy = dba_get_float_parm(&mc_home_preset, "5.home_position", "Joint.Hpp")


	{ steady type }
	dmy = dba_get_int_parm(&steady_type, "steady_type", "Parm") \
	
	machine_pose_prof 			= tg_prof_alloc(1, 6)	{ pose of spindle in machine }
	base_transform_prof			= tg_prof_alloc(1, 12)
	spindle_axis_prof			= tg_prof_alloc(3, 3)	
	world_spindle_axis_prof		= tg_prof_alloc(3, 3)
	spindle_points_prof			= tg_prof_alloc(24, 3)	{ spindle face approach points }
	world_spindle_points_prof	= tg_prof_alloc(24, 3)
	approach_thetas_prof		= tg_prof_alloc(1, 3)
    tool_def_prof  				= tg_prof_alloc(1, 6)

	probing_frate	= unitcv(60.0)	\
	fast_frate		= unitcv(320.0)	\

	RapApproach 	= 0.0			\
	NoTouch 		= 0		{ flag to record if a touch is missed } 		 \

    {define the nominal bar gripper tool frame}
	default_spindle_ref_posn = unitcv(-73.0)    {TODO:read this offset default for each machine type}
	tg_prof_write(tool_def_prof, 0.0, 0.0, default_spindle_ref_posn, 0.0, 0.0, 0.0, 0)

    {base transform is all zero because we are measuring the machine}
	tg_prof_write(base_transform_prof, -1.0, 0.0, 0.0, 0.0,   0.0, 0.0, 1.0, 0.0,   0.0, 1.0, 0.0, 0.0, 0)

	{probe and arbor parameters}
	probe_ball_dia = unitcv(2.0)	{TODO: user input}

	standoff_dist = unitcv(15)		{distance to retract from bar surface}
	slow_probe_dist = unitcv(3)		{distance of slow feed probe move}
 
	spindle_face_rad = 30.0
	a_axis_step = 25.0 {degrees}

	{generate probe points for probing spindle front face}
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(0)	,	spindle_face_rad*sin(0)	,	standoff_dist,	0	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(0)	,	spindle_face_rad*sin(0)	,	0	,	1	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(30)	,	spindle_face_rad*sin(30)	,	standoff_dist,	2	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(30)	,	spindle_face_rad*sin(30)	,	0	,	3	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(60)	,	spindle_face_rad*sin(60)	,	standoff_dist,	4	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(60)	,	spindle_face_rad*sin(60)	,	0	,	5	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(90)	,	spindle_face_rad*sin(90)	,	standoff_dist,	6	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(90)	,	spindle_face_rad*sin(90)	,	0	,	7	)
    

	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(120)	,	spindle_face_rad*sin(120)	,	standoff_dist,	8	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(120)	,	spindle_face_rad*sin(120)	,	0	,	9	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(150)	,	spindle_face_rad*sin(150)	,	standoff_dist,	10	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(150)	,	spindle_face_rad*sin(150)	,	0	,	11	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(180)	,	spindle_face_rad*sin(180)	,	standoff_dist,	12	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(180)	,	spindle_face_rad*sin(180)	,	0	,	13	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(210)	,	spindle_face_rad*sin(210)	,	standoff_dist,	14	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(210)	,	spindle_face_rad*sin(210)	,	0	,	15	)

    
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(240)	,	spindle_face_rad*sin(240)	,	standoff_dist,	16	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(240)	,	spindle_face_rad*sin(240)	,	0	,	17	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(270)	,	spindle_face_rad*sin(270)	,	standoff_dist,	18	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(270)	,	spindle_face_rad*sin(270)	,	0	,	19	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(300)	,	spindle_face_rad*sin(300)	,	standoff_dist,	20	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(300)	,	spindle_face_rad*sin(300)	,	0	,	21	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(330)	,	spindle_face_rad*sin(330)	,	standoff_dist,	22	)
	tg_prof_write(spindle_points_prof,	spindle_face_rad*cos(330)	,	spindle_face_rad*sin(330)	,	0	,	23	)
		
	{ define known axis center points in arbor frame for guess}
	tg_prof_write(spindle_axis_prof, 0, 0, 0, 0)	
	tg_prof_write(spindle_axis_prof, 0, 0, 100, 1) 
	tg_prof_write(spindle_axis_prof, 0, 0, 115, 2)	
    
    x_retract = unitcv(50.0)

subend	{ init_local_var }

{********************************************************
* Subroutine  :	reset_ack_latch
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
* Subroutine  :	wait_for_ack
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

{********************************************************
* Subroutine  :	measure_spindle_face
* Description :	probe the arbor
*********************************************************}
sub measure_spindle_face
    
	{ generate a set of approach points for the current pose }
	gbif_result = gbif("probe_point_gen", machine_pose_prof, tool_def_prof, base_transform_prof, spindle_points_prof,\
					   spindle_axis_prof, world_spindle_axis_prof, world_spindle_points_prof, approach_thetas_prof) 
    
	AppPoint    = 0 { index for probe point matrix }
    
	{ probe the bar}
	calls "probe_spindle_auto"
	
subend { measure_spindle_face }	


{*************************************************************************
* Subroutine  : probe_spindle_auto
* Description :	Auto Probing - read calculated approach and target points and probe
***************************************************************************}
sub probe_spindle_auto

	workpiece   		{ clear all existing workpiece offsets }
	posnlatch   		{ obtain current the position of the effector point }
	{TODO: set workpiece to previously calculated probe ball center}
	workpiece x(unitcv(G_POSN_UF0) - (x_eot - (probe_ball_dia/2) - (arbor_dia/2)))  { move workpiece coord to center of probe ball }

	posnlatch
	x_start = unitcv(g_posn_uf0) \
	y_start = unitcv(g_posn_uf1) \
	z_start = unitcv(g_posn_uf2)
	
	select_active_probe(3)
	
	{ Initialize the machine for probing }
	PROBING_BEGIN()		

	F(fast_frate)		{ set feedrate }
	conRow  = 0			{ index for contact point matrix }

	N25
	if (conRow < 12) then
		tg_prof_read(world_spindle_points_prof, &AppX, &AppY, &AppZ, AppPoint) { Approach point }
		AppX = unitcv(AppX) \
		AppY = unitcv(AppY) \
		AppZ = unitcv(AppZ) \
		AppZ = (-1) * AppZ  { invert Z coord }

		if ((AppPoint = 0) ) Z(AppZ)	
		
		rapid
			X(AppX) Y(AppY) Z(AppZ)	
		
		AppPoint = AppPoint + 1
		
		tg_prof_read(world_spindle_points_prof, &TarX, &TarY, &TarZ, AppPoint) { Target point }
		TarX = unitcv(TarX) \
		TarY = unitcv(TarY) \
		TarZ = unitcv(TarZ) \
		TarZ = (-1) * TarZ  { invert Z coord }
		AppPoint = AppPoint + 1

		probe_reenable() 
		
		{find the length of the vector}
		vec_length = sqrt((TarX - AppX)*(TarX - AppX) + (TarY - AppY)*(TarY - AppY) + (TarZ - AppZ)*(TarZ - AppZ)) \

		{fraction of vector to move in rapid}
		RapApproach = (vec_length - ((probe_ball_dia)/2) - slow_probe_dist)/vec_length \

		{ define a vector from approach to target }
		AppVecX = RapApproach * (TarX - AppX) \
		AppVecY = RapApproach * (TarY - AppY) \
		AppVecZ = RapApproach * (TarZ - AppZ) \

		{ intermediate point to rapid to is some distance up Vec }
		RPointX = AppX + AppVecX \
		RPointY = AppY + AppVecY \
		RPointZ = AppZ + AppVecZ

		rapid			{ Rapid to intermediate approach point }
			X(RPointX) Y(RPointY) Z(RPointZ) STOPIFNOT XOLB555
		
		sync
		IF (XOLB555 = FALSE) then
			X(AppX) Y(AppY) Z(AppZ) { retract to the start if contact is made on the rapid }
		IFEND
        
        F(probing_frate)	{ set feedrate }

		linear 
			X(TarX) Y(TarY) Z(TarZ) STOPIFNOT XOLB555	{ move forward to contact point }
		PROBELATCH			{ Copy latched values into system variables }

		if (xolb555) then   { If xolb555 is still on then the probe didn't touch! }		
			NoTouch = 1
			linear 
				X(AppX) Y(AppY) Z(AppZ) { Retract the probe to approach point }
			GOTO N24
		IFEND		
	
		rapid	
			X(AppX) Y(AppY) Z(AppZ)		{ Retract the probe to approach point }
		
		zInv = -1 * G_PROBED_UF[2] { grinder coords arn't right hand rule.. }
		
        {record the probe contact point to the data file}
        OPEN ( &outdata, datafile, APPEND ) 
        WRITE ( outdata, "%f	%f 	%f	%f 	%f \n", G_PROBED_UF[0] - mx_home_preset, G_PROBED_UF[1] - my_home_preset, zInv - mz_home_preset, G_PROBED_UF[9], G_PROBED_UF[11] - mc_home_preset)
		
		conRow = conRow + 1
		GOTO N25 { go around again }
	ifend
	
	N24
	probing_end()		{ We are finished probing for now. }
	workpiece
subend { probe_spindle_auto }

{*******************************************************************
* Subroutine :  M I S S E D _ C H U C K
* Description : Aborts the cycle because the probe misses the 
*				with ball when xolb555=on 
********************************************************************}
sub missed_chuck

	probing_end()
	ep_warning	("probing move missed")
	m86 { for rx7 to cancel m89 preset of C offset }
	end

subend { missed_chuck }


{************************
*** M A I N   B O D Y ***
*************************}
tg_prof_free_all()
absolute
Rapid
clearsa		{ clear soft axes }
clearlo		{ clear live offsets }
EFF			{ clear loader effectors }
workpiece 	{ clear any workpiece offsets }
m86 		{ column centre }
sync
M1021		{ loader control off }
sync
calls "init_local_var"

mx_home_preset = unitcv(200) {TODO: delete this}

OPEN ( &outdata, datafile, OUTPUT ) {clear data file}
close (outdata)
    
X(mx_home_preset)
C(0)
Y(0) Z(0)

workpiece 	{ clear any workpiece offsets }
m86 		{ column centre }

X(mx_home_preset)
Y(0) Z(0)

c_angle = 0.0
a_angle = 0.0

for c_angle = -60.0 to -120.0 step -30.0 do
	workpiece 	{ clear any workpiece offsets }
	m86 		{ column centre }
    C(c_angle) A(a_angle)   {move the axes to measurement position}
    tg_prof_write(machine_pose_prof, 0.0, 0.0, 0.0, 0.0, c_angle, 0.0, 0)
    calls "measure_spindle_face"
    X(mx_home_preset)
    a_angle = a_angle + a_axis_step
forend

return

{ END OF FILE }
