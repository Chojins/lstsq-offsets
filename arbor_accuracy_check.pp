{********************************************************
* Subroutine  :	I N I T _ L O C A L _ V A R
* Description :	Initialises the local variables
*				Database parameters that are used throughout
*				the cycle are also initialised and retrieved.
*********************************************************}
sub init_local_var
	logfile = "p:/tg7/misc/arbor_probing_Log.txt"
    datafile = "P:/TG7/misc/arbor_accuracy_data.txt"

	timestamp = strdate() { strftime wrapper, defaults to "%c", so "%Y.%m.%d %H:%M:%S" etc }

	OPEN ( &outdata, logfile, APPEND ) 
	WRITE ( outdata, " Machine Offsets Arbor Accuracy Check =================== \n %s \n", timestamp)
	close (outdata)

	dmy = dba_get_string_parm(&cyc_path,"tg.cyc_dir","dirs.dir")	\

	{ Home directory }
	dmy = dba_get_string_parm(&tga_home,"tga.home_dir","dirs.dir") 	\
	teach_home = tga_home+"/tcg/ppsys/ldm/rbt/auto_teach"			\
	
	{ grinder x home position }	
	dmy = dba_get_float_parm(&mx_home_preset, "1.home_position", "Joint.Hpp") \
	mx_home_preset = unitcv(mx_home_preset) \

	{read db spindle ref position}	
	dba_get_float_parm(&spindle_ref_posn_current, "spindle_ref_posn", "spindle_ref_posn")
	spindle_ref_posn_current = unitcv(spindle_ref_posn_current)

	{values obtained from notebook - in metric}
	ball_runout = unitcv(ipf100)
	ball_runout_angle = ipf101
	arbor_radius = unitcv(ipf102)
    spindle_centerline_offset = unitcv(ipf103)
    x_offset = unitcv(ipf104)
	y_home_offset = unitcv(ipf105)
	z_home_offset = unitcv(ipf106)
	c_home_offset = unitcv(ipf107)
	spindle_ref_posn = unitcv(ipf108)
	
	probe_ball_dia = unitcv(ipf110)
	ball_radius = probe_ball_dia/2
    
    arbor_dia = arbor_radius*2
	
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
	tg_prof_write(BarToolDef, 0.0, 0.0, spindle_ref_posn_current, 0.0, 0.0, 0.0, 0)

    {base transform is all zero because we are measuring the machine}
	tg_prof_write(BaseTransform, -1.0, 0.0, 0.0, 0.0,   0.0, 0.0, 1.0, 0.0,   0.0, 1.0, 0.0, 0.0, 0)

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
* Subroutine  :	measure_bar_tool
* Description :	probe the arbor
*********************************************************}
sub measure_bar_tool
    
	{ generate a set of approach points for the current pose }
	gbif_result = gbif("probe_point_gen", ArborPose, BarToolDef, BaseTransform, pBarPoints,\
					   pBarAxisNom, wBarAxisNom, wBarPoints, approachThetas) 
                       
    {gbif("writePDToFile", wBarPoints, 24, 3, logfile, "wBarPoints", 1, 1)}

	AppPoint    = 0 { index for probe point matrix }
    
	{ probe the bar}
	calls "probe_bar_auto"
	
subend { measure_bar_tool }	


{*************************************************************************
* Subroutine  : apply_probe_workpiece
* Description :	move the workpiece offset to the probe ball center.
***************************************************************************}
sub apply_probe_workpiece
    workpiece
    X(mx_home_preset)
    Y(0) Z(0)

	workpiece   		{ clear all existing workpiece offsets }
	posnlatch   		{ obtain current the position of the effector point }

	a_angle_degrees = g_posn_uf9

	probe_workpiece_x = x_offset
	probe_workpiece_y = ball_runout*sin(ball_runout_angle + a_angle_degrees)
	probe_workpiece_z = -ball_runout*cos(ball_runout_angle + a_angle_degrees)

	workpiece x(probe_workpiece_x) y(probe_workpiece_y) z(probe_workpiece_z) { move workpiece coord to center of probe ball }
    
    OPEN ( &outdata, logfile, APPEND ) 
    WRITE ( outdata, "probe_workpiece_x = %f probe_workpiece_y = %f probe_workpiece_z = %f\n", probe_workpiece_x, probe_workpiece_y, probe_workpiece_z)
    close (outdata)


subend { apply_probe_workpiece }

{*************************************************************************
* Subroutine  : probe_bar_auto
* Description :	Auto Probing - read calculated approach and target points and probe
***************************************************************************}
sub probe_bar_auto

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
		
        {calculate the position error and record to the data file}
		{find equation of the c-axis vector}
		c_angle_degrees = G_PROBED_UF[11]

		contact_x = unitcv(G_PROBED_UF[0])
		contact_y = unitcv(G_PROBED_UF[1])
		contact_z = unitcv(zInv)

        ui = -sin(c_angle_degrees)
        uj = cos(c_angle_degrees)
        uk = 0

		{coords of the spindle axis origin}
        spindle_origin_x = cos(c_angle_degrees)*(-spindle_centerline_offset)
        spindle_origin_y = sin(c_angle_degrees)*(-spindle_centerline_offset)
        spindle_origin_z = 0
        
        {find the closest point on the spindle axis}
        closest_point_x = spindle_origin_x + ((contact_x-spindle_origin_x)*ui+(contact_y-spindle_origin_y)*uj+(contact_z-spindle_origin_z)*uk)*ui
        closest_point_y = spindle_origin_y + ((contact_x-spindle_origin_x)*ui+(contact_y-spindle_origin_y)*uj+(contact_z-spindle_origin_z)*uk)*uj
        closest_point_z = spindle_origin_z + ((contact_x-spindle_origin_x)*ui+(contact_y-spindle_origin_y)*uj+(contact_z-spindle_origin_z)*uk)*uk

		error_calc = sqrt(((closest_point_x - contact_x)*(closest_point_x - contact_x) + (closest_point_y - contact_y)*(closest_point_y - contact_y) + (closest_point_z - contact_z)*(closest_point_z - contact_z))) - (ball_radius + arbor_radius)

        OPEN ( &outdata, datafile, APPEND ) 
        WRITE ( outdata, "%f	%f	%f	%f	%f	%f	%f	%f\n", contact_x, contact_y, contact_z, closest_point_x, closest_point_y, closest_point_z, c_angle_degrees, error_calc)
		close (outdata)

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

for c_angle = -5.0 to -25.0 step -10.0 do
    C(c_angle) A(a_angle)   {move the axes to measurement position}
    tg_prof_write(ArborPose, 0.0, 0.0, 0.0, 0.0, c_angle, 0.0, 0)
    calls "measure_bar_tool"
    X(mx_home_preset)
    a_angle = a_angle + 25
forend

for c_angle = -145.0 to -155 step -10.0 do {watch out for steady bed!}
    C(c_angle) A(a_angle)   {move the axes to measurement position}
    tg_prof_write(ArborPose, 0.0, 0.0, 0.0, 0.0, -c_angle, 180.0, 0)
    calls "measure_bar_tool"
    X(mx_home_preset)
    a_angle = a_angle + 25
forend

C(0)

return

{ END OF FILE }
