
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
	tg_prof_write(BarToolDef, 0.0, 0.0, -73.0, 0.0, 0.0, 0.0, 0)    {spindle_ref_posn}

    {base transform is all zero because we are measuring the machine}
	tg_prof_write(BaseTransform, -1.0, 0.0, 0.0, 0.0,   0.0, 0.0, 1.0, 0.0,   0.0, 1.0, 0.0, 0.0, 0)

	{generate probe points for bar}
	tg_prof_write(pBarPoints,	-19.445	,	-19.445	,	90	,	0	)
	tg_prof_write(pBarPoints,	0	,	0	,	90	,	1	)
	tg_prof_write(pBarPoints,	-26.563	,	-7.118	,	90	,	2	)
	tg_prof_write(pBarPoints,	0	,	0	,	90	,	3	)
	tg_prof_write(pBarPoints,	-26.563	,	7.118	,	90	,	4	)
	tg_prof_write(pBarPoints,	0	,	0	,	90	,	5	)
	tg_prof_write(pBarPoints,	-19.445	,	19.445	,	90	,	6	)
	tg_prof_write(pBarPoints,	0	,	0	,	90	,	7	)
    

	tg_prof_write(pBarPoints,	-19.445	,	19.445	,	75	,	8	)
	tg_prof_write(pBarPoints,	0	,	0	,	75	,	9	)
    tg_prof_write(pBarPoints,	-26.563	,	7.118	,	75	,	10	)
	tg_prof_write(pBarPoints,	0	,	0	,	75	,	11	)
    tg_prof_write(pBarPoints,	-26.563	,	-7.118	,	75	,	12	)
	tg_prof_write(pBarPoints,	0	,	0	,	75	,	13	)
	tg_prof_write(pBarPoints,	-19.445	,	-19.445	,	75	,	14	)    
	tg_prof_write(pBarPoints,	0	,	0	,	75	,	15	)

    
	tg_prof_write(pBarPoints,	-19.445	,	-19.445	,	60	,	16	)    
	tg_prof_write(pBarPoints,	0	,	0	,	60	,	17	)
	tg_prof_write(pBarPoints,	-26.563	,	-7.118	,	60	,	18	)
	tg_prof_write(pBarPoints,	0	,	0	,	60	,	19	)
	tg_prof_write(pBarPoints,	-26.563	,	7.118	,	60	,	20	)
	tg_prof_write(pBarPoints,	0	,	0	,	60	,	21	)
	tg_prof_write(pBarPoints,	-19.445	,	19.445	,	60	,	22	)
	tg_prof_write(pBarPoints,	0	,	0	,	60	,	23	)
		
	{ define known axis center points in arbor frame for guess}
	tg_prof_write(pBarAxisNom, 0, 0, 0, 0)	
	tg_prof_write(pBarAxisNom, 0, 0, 100, 1) 
	tg_prof_write(pBarAxisNom, 0, 0, 115, 2)	

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
	gbif("writePDToFile", ArborPose, 1, 6, logfile, "ArborPose",1,1)
	gbif("writePDToFile", BarToolDef, 1, 6, logfile, "BarToolDef",1,1)
	gbif("writePDToFile", BaseTransform, 1, 12, logfile, "BaseTransform",1,1)	
    
	{ generate a set of approach points for the current pose }
	gbif_result = gbif("probe_point_gen", ArborPose, BarToolDef, BaseTransform, pBarPoints,\
					   pBarAxisNom, wBarAxisNom, wBarPoints, approachThetas) 
					   
	gbif("writePDToFile", approachThetas, 1, 3, logfile, "approachThetas",1,1)
	gbif("writePDToFile", wBarPoints, 24, 3, logfile, "wBarPoints",1,1)
	gbif("writePDToFile", wBarAxisNom, 3, 3, logfile, "wBarAxisNom",1,1)	
    
	AppPoint    = 0 { index for probe point matrix }
    
	{ probe the bar}
	RapApproach = 0.3	{TODO: tweak this to be quicker}
	CALLS "probe_bar_auto"
	
subend { measure_bar_tool }	


{*************************************************************************
* Subroutine  : probe_bar_auto
* Description :	Auto Probing - read calculated approach and target points and probe
***************************************************************************}
sub probe_bar_auto

	workpiece   		{ clear all existing workpiece offsets }
	posnlatch   		{ obtain current the position of the effector point }
	workpiece x(unitcv(G_POSN_UF0) - (X_EOT - unitcv(6.35)))  { move workpiece coord to center of 1/2" sphere }

	posnlatch
	x_start = unitcv(g_posn_uf0) \
	y_start = unitcv(g_posn_uf1) \
	z_start = unitcv(g_posn_uf2)
	
	select_active_probe(4)
	
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
		F(probing_frate)	{ set feedrate }

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
        WRITE ( outdata, "%f	%f 	%f	%f 	%f \n", G_PROBED_UF[0], G_PROBED_UF[1], zInv, a_angle, c_angle)
		
		conRow = conRow + 1
		GOTO N25 { go around again }
	ifend
	
	N24
	probing_end()		{ We are finished probing for now. }
	workpiece
subend { probe_bar_auto }


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

callp teach_home+"/rbt_com_auto_dig_end_ball.pp"
X_EOT = g_fv316

workpiece 	{ clear any workpiece offsets }
m86 		{ column centre }

X(mx_home_preset)

c_angle = 0.0
a_angle = 0.0

for c_angle = 0.0 TO -60.0 STEP -30.0 DO
    C(c_angle) A(a_angle)   {move the axes to measurement position}
    tg_prof_write(ArborPose, 0.0, 0.0, 0.0, 0.0, c_angle, 0.0, 0)
    calls "measure_bar_tool"
    X(mx_home_preset)
    a_angle = a_angle + 15
FOREND

for c_angle = -120.0 TO -180 STEP -30.0 DO
    C(c_angle) A(a_angle)   {move the axes to measurement position}
    tg_prof_write(ArborPose, 0.0, 0.0, 0.0, 0.0, -c_angle, 180.0, 0)
    calls "measure_bar_tool"
    X(mx_home_preset)
    a_angle = a_angle + 15
FOREND

return

{ END OF FILE }