
{********************************************************
* Subroutine  :	I N I T _ L O C A L _ V A R
* Description :	Initialises the local variables
*				Database parameters that are used throughout
*				the cycle are also initialised and retrieved.
*********************************************************}
sub init_local_var
	logfile = "p:/tg7/misc/arbor_probing_Log.txt"
    datafile = "P:/TG7/misc/arbor_probing_data.txt"

	timestamp = strdate() { strftime wrapper, defaults to "%c", so "%Y.%m.%d %H:%M:%S" etc }

	OPEN ( &outdata, logfile, APPEND ) 
	WRITE ( outdata, " Machine Offsets Arbor Probing =================== \n %s \n", timestamp)
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
	
	ArborPose 		= tg_prof_alloc(1, 6)	{ pose of arbor in machine }
	BaseTransform	= tg_prof_alloc(1, 12)
	pBarAxisNom		= tg_prof_alloc(3, 3)	{ Bar axis points }
	wBarAxisNom		= tg_prof_alloc(3, 3)
	pBarPoints		= tg_prof_alloc(24, 3)	{ Bar approach points }
	wBarPoints		= tg_prof_alloc(24, 3)
	approachThetas	= tg_prof_alloc(1, 3)
    BarToolDef  	= tg_prof_alloc(1, 6)

	probing_frate	= unitcv(60.0)	\
	fast_frate		= unitcv(320.0)	\

	RapApproach 	= 0.0			\
	NoTouch 		= 0		{ flag to record if a touch is missed } 		 \

    {define the nominal bar gripper tool frame}
	default_spindle_ref_posn = unitcv(-73.0)    {TODO:read this offset default for each machine type}
	tg_prof_write(BarToolDef, 0.0, 0.0, default_spindle_ref_posn, 0.0, 0.0, 0.0, 0)

    {base transform is all zero because we are measuring the machine}
	tg_prof_write(BaseTransform, -1.0, 0.0, 0.0, 0.0,   0.0, 0.0, 1.0, 0.0,   0.0, 1.0, 0.0, 0.0, 0)

	{probe and arbor parameters}
	probe_ball_dia = unitcv(3.0)	{TODO: user input}
	ipf110 = probe_ball_dia			{copy ball diameter to global variable}

	arbor_dia = unitcv(20.0)		{TODO: user input}
	standoff_dist = unitcv(15)		{distance to retract from bar surface}
	slow_probe_dist = unitcv(3)		{distance of slow feed probe move}

	probe_distance = standoff_dist + (probe_ball_dia + arbor_dia)/2

	{generate probe points for bar}
	tg_prof_write(pBarPoints,	-probe_distance*cos(90)	,	-probe_distance*sin(90)	,	90	,	0	)
	tg_prof_write(pBarPoints,	0	,	0	,	90	,	1	)
	tg_prof_write(pBarPoints,	-probe_distance*cos(45)	,	-probe_distance*sin(45)	,	90	,	2	)
	tg_prof_write(pBarPoints,	0	,	0	,	90	,	3	)
	tg_prof_write(pBarPoints,	-probe_distance*cos(45)	,	probe_distance*sin(45)	,	90	,	4	)
	tg_prof_write(pBarPoints,	0	,	0	,	90	,	5	)
	tg_prof_write(pBarPoints,	-probe_distance*cos(90)	,	probe_distance*sin(90)	,	90	,	6	)
	tg_prof_write(pBarPoints,	0	,	0	,	90	,	7	)
    

	tg_prof_write(pBarPoints,	-probe_distance*cos(90)	,	probe_distance*sin(90)	,	75	,	8	)
	tg_prof_write(pBarPoints,	0	,	0	,	75	,	9	)
    tg_prof_write(pBarPoints,	-probe_distance*cos(45)	,	probe_distance*sin(45)	,	75	,	10	)
	tg_prof_write(pBarPoints,	0	,	0	,	75	,	11	)
    tg_prof_write(pBarPoints,	-probe_distance*cos(45)	,	-probe_distance*sin(45)	,	75	,	12	)
	tg_prof_write(pBarPoints,	0	,	0	,	75	,	13	)
	tg_prof_write(pBarPoints,	-probe_distance*cos(90)	,	-probe_distance*sin(90)	,	75	,	14	)    
	tg_prof_write(pBarPoints,	0	,	0	,	75	,	15	)

    
	tg_prof_write(pBarPoints,	-probe_distance*cos(90)	,	-probe_distance*sin(90)	,	60	,	16	)    
	tg_prof_write(pBarPoints,	0	,	0	,	60	,	17	)
	tg_prof_write(pBarPoints,	-probe_distance*cos(45)	,	-probe_distance*sin(45)	,	60	,	18	)
	tg_prof_write(pBarPoints,	0	,	0	,	60	,	19	)
	tg_prof_write(pBarPoints,	-probe_distance*cos(45)	,	probe_distance*sin(45)	,	60	,	20	)
	tg_prof_write(pBarPoints,	0	,	0	,	60	,	21	)
	tg_prof_write(pBarPoints,	-probe_distance*cos(90)	,	probe_distance*sin(90)	,	60	,	22	)
	tg_prof_write(pBarPoints,	0	,	0	,	60	,	23	)
		
	{ define known axis center points in arbor frame for guess}
	tg_prof_write(pBarAxisNom, 0, 0, 0, 0)	
	tg_prof_write(pBarAxisNom, 0, 0, 100, 1) 
	tg_prof_write(pBarAxisNom, 0, 0, 115, 2)	
    
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
* Subroutine  :	measure_bar_tool
* Description :	probe the arbor
*********************************************************}
sub measure_bar_tool
    
	{ generate a set of approach points for the current pose }
	gbif_result = gbif("probe_point_gen", ArborPose, BarToolDef, BaseTransform, pBarPoints,\
					   pBarAxisNom, wBarAxisNom, wBarPoints, approachThetas) 
    
	AppPoint    = 0 { index for probe point matrix }
    
	{ probe the bar}
	calls "probe_bar_auto"
	
subend { measure_bar_tool }	


{*************************************************************************
* Subroutine  : apply_probe_workpiece
* Description :	move the workpiece offset to the probe ball center.
***************************************************************************}
sub apply_probe_workpiece

    
	workpiece x(probe_workpiece_x)  { move workpiece coord to center of probe ball }

	{TODO: apply known runout and offsets using workpiece?}
    


subend { apply_probe_workpiece }

{*************************************************************************
* Subroutine  : probe_bar_auto
* Description :	Auto Probing - read calculated approach and target points and probe
***************************************************************************}
sub probe_bar_auto

	workpiece   		{ clear all existing workpiece offsets }
	posnlatch   		{ obtain current the position of the effector point }
    
    calls "apply_probe_workpiece"
	
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
		tg_prof_read(wBarPoints, &AppX, &AppY, &AppZ, AppPoint) { Approach point }
		AppX = unitcv(AppX) \
		AppY = unitcv(AppY) \
		AppZ = unitcv(AppZ) \
		AppZ = (-1) * AppZ  { invert Z coord }

		if ((AppPoint = 0) ) Z(AppZ)	
		
		rapid
			X(AppX) Y(AppY) Z(AppZ)	
		
		AppPoint = AppPoint + 1
		
		tg_prof_read(wBarPoints, &TarX, &TarY, &TarZ, AppPoint) { Target point }
		TarX = unitcv(TarX) \
		TarY = unitcv(TarY) \
		TarZ = unitcv(TarZ) \
		TarZ = (-1) * TarZ  { invert Z coord }
		AppPoint = AppPoint + 1

		probe_reenable() 
		
		{find the length of the vector}
		vec_length = sqrt((TarX - AppX)*(TarX - AppX) + (TarY - AppY)*(TarY - AppY) + (TarZ - AppZ)*(TarZ - AppZ)) \

		{fraction of vector to move in rapid}
		RapApproach = (vec_length - ((probe_ball_dia + arbor_dia)/2) - slow_probe_dist)/vec_length \

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
        WRITE ( outdata, "%f	%f 	%f	%f 	%f \n", G_PROBED_UF[0] - probe_workpiece_x, G_PROBED_UF[1] - my_home_preset, zInv - mz_home_preset, G_PROBED_UF[9], G_PROBED_UF[11] - mc_home_preset)
		
		conRow = conRow + 1
		GOTO N25 { go around again }
	ifend
	
	N24
	probing_end()		{ We are finished probing for now. }
	workpiece
subend { probe_bar_auto }

{********************************************************
* Subroutine  :	dig_end_ball
* Description :	probe the sphere in the headstock 
*********************************************************}
sub dig_end_ball

	calls "move_headstock_to_arbor_mpg"

	select_active_probe(3) { 3 is the wheel probe input}

	probing_begin()
	
	linear
	f(probing_frate)	{ set feedrate }
		X(unitcv(-100.0)) stopifnot xolb555	{ Move to some negative position }

	probelatch
	sync
	waitplc(1)
	if xolb555 	calls  "missed_chuck"		{ did not touch the tool }

	relative
	rapid
		x(x_retract)       { relative instead of absolute to avoid
							probe breakage when probe is not reliable }
	absolute

	x_eot = unitcv(G_PROBED_UF0) 

	sync
	waitplc(1)
	probing_end()

	OPEN ( &outdata, logfile, APPEND ) 
	WRITE ( outdata, "x_eot_uf = %f, x_eot_jf = %f \n", unitcv(G_PROBED_UF0), unitcv(G_PROBED_JF0))
	close (outdata)
    
    probe_workpiece_x = unitcv(G_POSN_UF0) - (x_eot - (probe_ball_dia/2) - (arbor_dia/2))

	ipf111 = probe_workpiece_x	{copy to global for use by spindle probing program}
    
    OPEN ( &outdata, logfile, APPEND ) 
	WRITE ( outdata, "worpiece x applied = %f\n", probe_workpiece_x)
	close (outdata)



subend { dig_end_ball }

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

{ *************************************************************************
* Subroutine  : move_headstock_to_arbor_mpg
* Description : Allow MPG to a position, return when ack is pressed
*************************************************************************** }
sub move_headstock_to_arbor_mpg

	absolute
	callp cyc_path+"/tg_dis_axis"

	%XILB_SELECT_X_AXIS = on
 	callp cyc_path+"/tg_en_mpg"
	n100 if %GPB_ACK_LATCH goto n999
	
	wclose
	write("Jog probe in X to 5mm from arbor.\n\nPress <ACK> to probe.")
	
	%GPB_EXTERNAL_MPG_ACTIVATED = on
 	callp cyc_path+"/tg_en_mpg"
 	if %XILB_SELECT_X_AXIS callp cyc_path+"/tg_x_mpg"
  	if %XILB_SELECT_Y_AXIS callp cyc_path+"/tg_y_mpg"
  	if %XILB_SELECT_Z_AXIS callp cyc_path+"/tg_z_mpg"
	goto n100
n999 
	wclose
	%GPB_EXTERNAL_MPG_ACTIVATED = off

subend { move_headstock_to_arbor_mpg }

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

OPEN ( &outdata, datafile, OUTPUT ) {clear data file}
close (outdata)
    
X(mx_home_preset)
C(0)
Y(0) Z(0)

{jog probe tip to arbor in X}
calls "dig_end_ball"

workpiece 	{ clear any workpiece offsets }
m86 		{ column centre }

X(mx_home_preset)
Y(0) Z(0)

c_angle = 0.0
a_angle = 0.0

for c_angle = 0.0 to -30.0 step -10.0 do
    C(c_angle) A(a_angle)   {move the axes to measurement position}
    tg_prof_write(ArborPose, 0.0, 0.0, 0.0, 0.0, c_angle, 0.0, 0)
    calls "measure_bar_tool"
    X(mx_home_preset)
    a_angle = a_angle + 25
forend

for c_angle = -150.0 to -170 step -10.0 do {watch out for steady bed!}
    C(c_angle) A(a_angle)   {move the axes to measurement position}
    tg_prof_write(ArborPose, 0.0, 0.0, 0.0, 0.0, -c_angle, 180.0, 0)
    calls "measure_bar_tool"
    X(mx_home_preset)
    a_angle = a_angle + 25
forend

return

{ END OF FILE }
