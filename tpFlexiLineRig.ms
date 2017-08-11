--  tpFlexiLine
-- Tomas Poveda - www.cgart3d.com

--  Variables
prefix = "Flexi_"
anchorsNum = 5

try(destroyDialog ProgressBarTool.instUI;ProgressBarTool.instUI=undefined)catch()

--Structure containing the tool
struct ProgressBarTool
(
	/* 
	ProgressBar source:
			https://gist.github.com/JokerMartini/3e12ae1d8ef242c9d33c
	*/
	
	/********************************************************
	Variables
	********************************************************/
	instUI = undefined,
	message = "",
	count = 0,
	value = 0,
	
	/********************************************************
	Functions
	********************************************************/
	fn SetProgress value:0 count:0 message:"" =
	(		
		ProgressBarTool.count = count
		ProgressBarTool.value = value
		ProgressBarTool.message = message

		--Update the UI
		if instUI != undefined do 
		(
			instUI.UpdateProgress()
		)
	),
	
	/********************************************************
	Rollouts
	********************************************************/
	fn UI =
	(
		rollout ProgressBarToolRO "Progress..."
		(
			dotnetcontrol uiMessage "Label" width:(ProgressBarToolRO.width-28) align:#center offset:[0,5]
			progressbar uiProgressBar color:(color 20 150 240) width:(ProgressBarToolRO.width-28) height:12  align:#center
			dotnetcontrol uiIterations "Label" width:(ProgressBarToolRO.width-28) align:#center
			button uiOk "OK" width:100 align:#right enabled:false
						
			fn StyleLabel ctrl:undefined align:#left =
			(	
				colMax = (colorMan.getColor #background)*255
				colorClass = dotNetClass "system.drawing.color"
				ctrl.Font = dotNetObject "System.Drawing.Font" "Verdana" 11 (dotNetClass "System.Drawing.FontStyle").Regular (dotNetClass "System.Drawing.GraphicsUnit").Pixel
				ctrl.Backcolor = colMax = colorClass.fromArgb colMax[1] colMax[2] colMax[3]
				ctrl.Forecolor = ctrl.Forecolor.fromARGB 240 240 240
				ctrl.TextAlign = ctrl.TextAlign.TopLeft
			)

			fn UpdateProgress =
			(
				uiMessage.text = ProgressBarTool.message
				uiProgressBar.value = 100.0 * ProgressBarTool.value / ProgressBarTool.count as float
				uiIterations.text = ProgressBarTool.value as string + "/" + ProgressBarTool.count as string
				windows.processPostedMessages()

				uiOk.enabled = ProgressBarTool.value == ProgressBarTool.count
			)
			
			on uiOk pressed do
			(
				try(destroyDialog ::ProgressBarToolRO)catch()
			)
			
			on ProgressBarToolRO open do
			(
				StyleLabel ctrl:uiMessage
				StyleLabel ctrl:uiIterations
			)
		)
	),
	
	fn run=
	(
		if instUI==undefined then
		(
			instUI=UI()
			createDialog instUI width:500 style:#(#style_titlebar, #style_border)
		)else
		(
			destroyDialog instUI
			instUI=undefined
		)
	),

	fn getRollouts = #(ui())
)

----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- Function that creates a line between 3 points
fn drawInitialLineThreePoints pointA pointB pointC =
(
	spline = SplineShape pos:pointA
	addNewSpline spline
	addKnot spline 1 #corner #line pointA
	addKnot spline 1 #corner #line pointB
	addKnot spline 1 #corner #line pointC
	updateShape spline
	spline
)

-- Function that freeze transform for an object
fn FreezeTransform obj =
(
	local curObj = obj
	
	if classOf curObj.rotation.controller != Rotation_Layer do
	(
		-- Freeze rotation
		curObj.rotation.controller = Euler_Xyz()
		curObj.rotation.controller = Rotation_List()
		curObj.rotation.controller.available.controller = Euler_Xyz()
		
		-- Rename new rotation controllers
		curObj.rotation.controller.SetName 1 "Frozen Rotation"
		curObj.rotation.controller.SetName 2 "Zero Euler XYZ"
		
		-- Set new controller
		curObj.rotation.controller.SetActive 2
	)
	
	if classOf curObj.position.controller != Position_Layer do
	(
		-- Freeze position
		curObj.position.controller = Bezier_Position()
		curObj.position.controller = Position_List()
		curObj.position.controller.available.controller = Position_XYZ()
		
		-- Rename new position controllers
		curObj.position.controller.SetName 1 "Frozen Position"
		curObj.position.controller.SetName 2 "Zero Pos XYZ"
		
		-- Set new controller
		curObj.position.controller.SetActive 2
		
		-- Reeset position controllers to 0
		curObj.position.controller[2].x_Position = 0
		curObj.position.controller[2].y_Position = 0
		curObj.position.controller[2].z_Position = 0
	)
)

-- Function that creates a point helper
fn CreatePointHelper myPos mySize myCentermarker myAxisTripod myCross myBox =
(	
	
	myPoint = Point pos:myPos size:mySize centermarker:myCentermarker  axistripod: myAxisTripod cross:myCross box:myBox
	myPoint
)

-- Function that returns an alphabetic value given an integer value
fn GetAlphabeticValue myValue =
(
	myLetter = case myValue of
	(
		1: "A"
		2: "B"
		3: "C"
		4: "D"
		5: "E"
		6: "F"
		7: "G"
		8: "H"
		9: "I"
		10: "J"
		11: "K"
		12: "L"
		13: "M"
		14: "N"
		15: "O"
		16: "P"
		17: "Q"
		18: "R"
		19: "S"
		20: "T"
		21: "U"
		22: "V"
		23: "W"
		24: "X"
		25: "Y"
		26: "Z"
		default: "MAX_VALUE"
	)
	myLetter
)

-- Function that returns a numerical index
fn GetNumericalValue myValue =
(
	numericalValue = ""
	
	if myValue < 10 then
		numericalValue = "0" + myValue as string
	else numericalValue = myValue
		
	numericalValue
)

-- Function that creates a square curve
fn CreateSquareCurve initPos =
(
	posA = initPos
	posB = [posA.x + 20, posA.y, posA.z]
	posC = [posA.x + 20, posA.y - 20, posA.z]
	posD = [posA.x, posA.y - 20, posA.z]
	
	square = SplineShape pos:posA
	addNewSpline square
	addKnot square 1 #corner #line posA
	addKnot square 1 #corner #line posB
	addKnot square 1 #corner #line posC
	addKnot square 1 #corner #line posD
	close square 1
	updateShape square
	square
)

-- Function that creates a triangle curve
fn CreateTriangleCurve initPos =
(
	posA = initPos
	posB = [posA.x + 20, posA.y, posA.z]
	posC = [posA.x + 10, posA.y + 10, posA.z]
	
	triangle = SplineShape pos:posA
	addNewSpline triangle
	addKnot triangle 1 #corner #line posA
	addKnot triangle 1 #corner #line posB
	addKnot triangle 1 #corner #line posC
	close triangle 1
	updateShape triangle
	
	trianglePivotPos = CenterPosBetweenThreePoints posA posB posC
	triangle.pivot = trianglePivotPos
	
	triangle
)

-- Function to align to objects in positoin
fn QuickAlign objToMove target =
(
	objToMove.position = target.position
)

-- Function to align objects pivots
fn QuickPivotAlign objToMove target =
(
	objToMove.pivot = target.position
)

-- Function that combines two splines
fn AddShape spline1 spline2 = if isKindOf spline1 SplineShape and isKindOf spline2 SplineShape do
(
	convertToSplineShape spline1
	convertToSplineShape spline2
	addAndWeld spline1 spline2 -1
	spline1
)

-- Function that returns the center position between three objects
fn CenterPosBetweenThreePoints pointA pointB pointC =
(
	newPos = [0, 0, 0]
	newPos.x = (pointA.x + pointB.x + pointC.x)/3.0
	newPos.y = (pointA.y + pointB.y + pointC.y)/3.0
	newPos.z = (pointA.z + pointB.z + pointC.z)/3.0
	newPos
)

-- Function to aset bone weights for a SkinModifier
fn SetBoneWeight objWithSkin boneID vertexID weight = 
(
	subobjectLevel = 1
	objWithSkin.modifiers[#Skin].filter_vertices = on
	skinOps.SelectBone objWithSkin.modifiers[#Skin] boneID
	skinOps.SelectVertices objWithSkin.modifiers[#Skin] #{vertexID}
	skinOps.setWeight objWithSkin.modifiers[#Skin] weight
)

---------------------------------------------------------------------------------------------
-- MAIN FUNCTION
---------------------------------------------------------------------------------------------
fn createFlexiSystem =
(
	-- Progress bar for the rigging process
	ProgressBarTool = ProgressBarTool()
	ProgressBarTool.run()
	
	local currStep  = 1
	local numSteps = 3
	
	if flexiRollout.chkTwist.state == True then 
	(
		numSteps = numSteps + 1
	)
	
	if flexiRollout.chkStretch.state == True then
	(
		numSteps = numSteps + 1
	)
	
	ProgressBarTool.SetProgress value:currStep count:numSteps message:"Creating spline setup ..." 
	currStep = currStep + 1
	
	try
	(
		-- Create initial spline
		spline = drawInitialLineThreePoints [0,-10,0] [0,0,0] [0,10,0]
		spline.name = prefix + "Line01"
		spline.render_displayRenderMesh = false
		CenterPivot spline
		FreezeTransform spline

		-- Creamos system anchor points
		anchors  =#()
		for i = 1 to anchorsNum do
		(
			pathPercent = (i-1)*25.0
			
			anchors[i] = CreatePointHelper [0,0,0] 5.0 true false false false
			anchors[i].name = prefix + "Anchor_" + GetAlphabeticValue i + "01"
			anchors[i].position.controller = Path_Constraint percent:pathPercent
			anchors[i].position.controller.path = spline
			anchors[i].isSelected = true
			macros.run "Animation Tools" "DeleteSelectedAnimation"
		)
		
		ProgressBarTool.SetProgress value:currStep count:numSteps message:"Creating controls ..." 
		currStep = currStep + 1
		
		-- Create main controls (start/end)
		startEndControls = #()
		for i = 1 to 2 do
		(
			startEndControls[i] = CreateSquareCurve [-10, 10, 0]
			
			if i == 1 then
				startEndControls[i].name = prefix + "Ctrl_Start01"
			else
				startEndControls[i].name = prefix + "Ctrl_End01"
			
			CenterPivot startEndControls[i]
			startEndControls[i].scale *= 0.15
			
			if i == 1 then
				QuickAlign startEndControls[i] anchors[1]
			else
				QuickAlign startEndControls[i] anchors[anchorsNum]
			
			ResetXForm startEndControls[i]
			collapseStack startEndControls[i]
			FreezeTransform startEndControls[i]
			
			startEndControls[i].wirecolor = color 225 197 86 255
			
			startEndControls[i].render_displayRenderMesh = true
			startEndControls[i].render_viewport_rectangular = false
			startEndControls[i].render_thickness = 0.5
		)

		-- Create mid control (bend)
		bendControl1 = circle radius:2.0
		bendControl2 = circle radius:2.0
		bendControl2.rotation = eulerAngles -90 0 0
		convertToSplineShape bendControl1
		convertToSplineShape bendControl2
		bendControl = AddShape bendControl1 bendControl2
		bendControl.name = prefix + "Ctrl_Mid_Bend01"
		bendControl.wirecolor = color 225 197 86 255
		ResetXForm bendControl
		collapseStack bendControl
		FreezeTransform bendControl
		bendControl.render_displayRenderMesh = true
		bendControl.render_viewport_rectangular = false
		bendControl.render_thickness = 0.5

		-- Create global control
		globalControl1 = CreateTriangleCurve [10, -10, 0]
		globalControl1.scale.x = 0.65
		globalControl1.position = [10, 0, 0]
		globalControl1.scale *= 0.4
		move globalControl1 [-3.0, 0, 0]
		globalControl2 = copy globalControl1
		globalControl2.position = [-10, 0, 0]
		move globalControl2 [3.0, 0, 0]
		globalControl = AddShape globalControl1 globalControl2
		globalControl.name = prefix + "Ctrl_Global01"
		globalControl.wirecolor = color 225 197 86 255
		globalControl.pivot = [0, 0, 0]
		ResetXForm globalControl
		collapseStack globalControl
		FreezeTransform globalControl
		globalControl.render_displayRenderMesh = true
		globalControl.render_viewport_rectangular = false
		globalControl.render_thickness = 0.5

		-- Link al controls  and anchor points to the global control
		startEndControls[1].parent = globalControl
		startEndControls[2].parent = globalControl
		bendControl.parent = globalControl
		FreezeTransform startEndControls[1]
		FreezeTransform startEndControls[2]
		FreezeTransform bendControl

		for i = 1 to anchorsNum do
		(
			anchors[i].parent = globalControl
			-- NOTA: In this case, do not freeze transforms. If we do it we will lose the path contstraint
		)

		-- Mid control (bend) must be always located between start and end control
		bendControlGroupName = prefix + "Mid_Bend_GRP01"
		bendControlGroup = group bendControl name:bendControlGroupName 
		setGroupOpen bendControlGroup true
		FreezeTransform bendControl
		FreezeTransform bendControlGroup

		bendControlGroup.position.controller = Position_Constraint()
		bendControlGroup.position.controller.constraints.appendTarget startEndControls[1] 1
		bendControlGroup.position.controller.constraints.appendTarget startEndControls[2] 1

		-- Apply skin modifier to the Spline. It will be deformed by the controls (start, mid, end)
		select spline
		currCommandPanelTaskMode = GetCommandPanelTaskMode()
		SetCommandPanelTaskMode mode:#modify
		modPanel.addModToSelection (Skin ())
		skinOps.addBone spline.modifiers[#Skin] startEndControls[1] 1
		skinOps.addBone spline.modifiers[#Skin] startEndControls[2] 1
		skinOps.addBone spline.modifiers[#Skin] bendControl 1

		--SetBoneWeight objWithSkin boneID vertexID weight
		SetBoneWeight spline 1 1 1.0
		SetBoneWeight spline 1 2 1.0
		SetBoneWeight spline 2 8 1.0
		SetBoneWeight spline 2 9 1.0
		SetBoneWeight spline 3 5 1.0
		modPanel.setCurrentObject spline.modifiers[#Skin]
		SetCommandPanelTaskMode mode:currCommandPanelTaskMode
			
		-- Twistign system
		-- Create main twist helpers
		twistHelpers  =#()
		for i = 1 to anchorsNum do
		(
			twistHelpers[i] = copy anchors[i]
			twistHelpers[i].box = true
			twistHelpers[i].centermarker = false
			twistHelpers[i].size = 3
			twistHelpers[i].name = prefix + "BnDrv_" + GetAlphabeticValue i + "01"
			
			twistHelpers[i].parent = anchors[i]
			FreezeTransform twistHelpers[i]
			QuickAlign twistHelpers[i] anchors[i]
			FreezeTransform twistHelpers[i]
		)
		
		if flexiRollout.chkTwist.state == True do
		(
			ProgressBarTool.SetProgress value:currStep count:numSteps message:"Creating twisting system ..." 
			currStep = currStep + 1
			
			-- Create helpers that will control the rotation of the main twist helpers
			twistHelpersRotation = #()
			for i = 1 to anchorsNum do
			(
				twistHelpersRotation[i] = copy twistHelpers[i]
				twistHelpersRotation[i].box = false
				twistHelpersRotation[i].cross = true
				twistHelpersRotation[i].size = 2
				twistHelpersRotation[i].name = prefix + "UpVector_" + GetAlphabeticValue i + "01"
				move twistHelpersRotation[i] [0, 0, 5]
			)
			
			twistHelpersRotationGroups = #()
			for i = 1 to anchorsNum do
			(
				twistHelpersRotationGroups[i] = group twistHelpersRotation[i]
				twistHelpersRotationGroups[i].name = prefix + "UpVector_" + GetAlphabeticValue i + "_GRP01"
				setGroupOpen twistHelpersRotationGroups[i] true
				QuickPivotAlign twistHelpersRotationGroups[i] anchors[i]
				FreezeTransform twistHelpersRotation[i]
				FreezeTransform twistHelpersRotationGroups[i]
			)

			-- Create LookAt constraints
			for i = 1 to anchorsNum do
			(
				if i < anchorsNum then
				(
					twistHelpers[i].rotation.controller.available.controller = LookAt_Constraint()
					twistHelpers[i].rotation.controller.SetActive 3
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.appendTarget anchors[i+1] 1
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.lookat_vector_length = 0.0
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.viewline_length_abs  = false
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.upnode_ctrl = 0
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.upnode_world = off
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.pickUpNode = twistHelpersRotation[i]
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.target_axis = 1
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.upnode_axis = 0
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.StoUP_axis = 2
				)
				else
				(
					twistHelpers[i].rotation.controller.available.controller = LookAt_Constraint()
					twistHelpers[i].rotation.controller.SetActive 3
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.appendTarget anchors[i-1] 1
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.lookat_vector_length = 0.0
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.viewline_length_abs  = false
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.upnode_ctrl = 0
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.upnode_world = off
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.pickUpNode = twistHelpersRotation[i]
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.target_axis = 1
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.upnode_axis = 0
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.StoUP_axis = 2
					twistHelpers[i].rotation.controller.LookAt_Constraint.controller.StoUP_axisFlip = on
				)
			)
		
			-- Connect parameters and controllers
			paramwire.connect startEndControls[1].rotation.controller.Zero_Euler_XYZ.controller[#Y_Rotation] twistHelpersRotationGroups[1].rotation.controller.Zero_Euler_XYZ.controller[#Y_Rotation] "Y_Rotation"
			paramwire.connect startEndControls[2].rotation.controller.Zero_Euler_XYZ.controller[#Y_Rotation] twistHelpersRotationGroups[5].rotation.controller.Zero_Euler_XYZ.controller[#Y_Rotation] "Y_Rotation"

			twistHelpersRotationGroups[3].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller = Float_Expression()
			twistHelpersRotationGroups[3].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller.AddScalarTarget "start_twist" startEndControls[1].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller
			twistHelpersRotationGroups[3].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller.AddScalarTarget "end_twist" startEndControls[2].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller
			twistHelpersRotationGroups[3].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller.SetExpression "(start_twist + end_twist) / 2"
			twistHelpersRotationGroups[2].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller = Float_Expression()
			twistHelpersRotationGroups[2].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller.AddScalarTarget "start_twist" startEndControls[1].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller
			twistHelpersRotationGroups[2].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller.AddScalarTarget "mid_twist" twistHelpersRotationGroups[3].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller
			twistHelpersRotationGroups[2].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller.SetExpression "(start_twist + mid_twist) / 2"
			twistHelpersRotationGroups[4].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller = Float_Expression()
			twistHelpersRotationGroups[4].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller.AddScalarTarget "end_twist" startEndControls[2].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller
			twistHelpersRotationGroups[4].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller.AddScalarTarget "mid_twist" twistHelpersRotationGroups[3].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller
			twistHelpersRotationGroups[4].rotation.controller.Zero_Euler_XYZ.controller.Y_Rotation.controller.SetExpression "(end_twist + mid_twist) / 2"

			-- Block rotation axis
			setTransformLockFlags startEndControls[1]  #{4,6,7,8,9}
			setTransformLockFlags startEndControls[2]  #{4,6,7,8,9}
			setTransformLockFlags bendControl #{4..9}
		)
		
		--print("Activating Squash and Stretch system")
		
		if flexiRollout.chkStretch.state == True do
		(	
			ProgressBarTool.SetProgress value:currStep count:numSteps message:"Creating squash and stretch system ..." 
			currStep = currStep + 1
			
			-- Squash & Stretch System
			twistHelpers[2].scale.controller = ScaleXYZ()
			twistHelpers[3].scale.controller = ScaleXYZ()
			twistHelpers[4].scale.controller = ScaleXYZ()
			globalControl.scale.controller = ScaleXYZ()

			-- Calculate distance to apply squash stretch
			exposeDistance = ExposeTm()
			exposeDistance.name = prefix + "Distance01"
			exposeDistance.cross = false
			exposeDistance.axisTripod = true
			exposeDistance.size = 4
			exposeDistance.parent = globalControl
			exposeDistance.useParent = off
			exposeDistance.exposeNode = anchors[2]
			exposeDistance.localReferenceNode = anchors[4]
			initDistance = exposeDistance.Distance as string	-- Nos almacenamos la distancia inicial

			-- Add custom attributes to the global control
			select globalControl
			currCommandPanelTaskMode = GetCommandPanelTaskMode()
			SetCommandPanelTaskMode mode:#modify
			modPanel.addModToSelection (EmptyModifier ())

			ca = attributes globalControlControls
			(
				parameters params rollout:globalControlsRollout
				(
					active type:#boolean ui:activeBoolean
				)
				
				rollout globalControlsRollout "Flexi-System Controls"
				(
					checkbox activeBoolean "Activar Squash Stretch"
				)
			)
			custAttributes.add globalControl.modifiers[1] ca

			globalControl.modifiers[#Attribute_Holder].globalControlControls.active.controller = Bezier_Float()

			SetCommandPanelTaskMode mode:currCommandPanelTaskMode

			-- Apply squash and stretch expression to respective controllers
			twistHelpers[2].scale.controller.X_Scale.controller = Float_Expression()
			twistHelpers[2].scale.controller.X_Scale.controller.AddScalarTarget "length" exposeDistance.distance.controller
			twistHelpers[2].scale.controller.X_Scale.controller.AddScalarTarget "global" globalControl.scale.controller.Y_Scale.controller
			twistHelpers[2].scale.controller.X_Scale.controller.AddScalarTarget "active" globalControl.modifiers[#Attribute_Holder].globalControlControls.active.controller
			twistHelpers[2].scale.controller.X_Scale.controller.SetExpression "if(active=1,(pow((10 * global / length), 0.5)), 1)"
			twistHelpers[2].scale.controller.Z_Scale.controller = Float_Expression()
			twistHelpers[2].scale.controller.Z_Scale.controller.AddScalarTarget "length" exposeDistance.distance.controller
			twistHelpers[2].scale.controller.Z_Scale.controller.AddScalarTarget "global" globalControl.scale.controller.Y_Scale.controller
			twistHelpers[2].scale.controller.Z_Scale.controller.AddScalarTarget "active" globalControl.modifiers[#Attribute_Holder].globalControlControls.active.controller
			twistHelpers[2].scale.controller.Z_Scale.controller.SetExpression "if(active=1,(pow((10 * global / length), 0.5)), 1)"

			twistHelpers[3].scale.controller.X_Scale.controller = Float_Expression()
			twistHelpers[3].scale.controller.X_Scale.controller.AddScalarTarget "length" exposeDistance.distance.controller
			twistHelpers[3].scale.controller.X_Scale.controller.AddScalarTarget "global" globalControl.scale.controller.Y_Scale.controller
			twistHelpers[3].scale.controller.X_Scale.controller.AddScalarTarget "active" globalControl.modifiers[#Attribute_Holder].globalControlControls.active.controller
			twistHelpers[3].scale.controller.X_Scale.controller.SetExpression "if(active=1,(10 * global / length), 1)"
			twistHelpers[3].scale.controller.Z_Scale.controller = Float_Expression()
			twistHelpers[3].scale.controller.Z_Scale.controller.AddScalarTarget "length" exposeDistance.distance.controller
			twistHelpers[3].scale.controller.Z_Scale.controller.AddScalarTarget "global" globalControl.scale.controller.Y_Scale.controller
			twistHelpers[3].scale.controller.Z_Scale.controller.AddScalarTarget "active" globalControl.modifiers[#Attribute_Holder].globalControlControls.active.controller
			twistHelpers[3].scale.controller.Z_Scale.controller.SetExpression "if(active=1,(10 * global / length), 1)"

			twistHelpers[4].scale.controller.X_Scale.controller = Float_Expression()
			twistHelpers[4].scale.controller.X_Scale.controller.AddScalarTarget "length" exposeDistance.distance.controller
			twistHelpers[4].scale.controller.X_Scale.controller.AddScalarTarget "global" globalControl.scale.controller.Y_Scale.controller
			twistHelpers[4].scale.controller.X_Scale.controller.AddScalarTarget "active" globalControl.modifiers[#Attribute_Holder].globalControlControls.active.controller
			twistHelpers[4].scale.controller.X_Scale.controller.SetExpression "if(active=1,(pow((10 * global / length), 0.5)), 1)"
			twistHelpers[4].scale.controller.Z_Scale.controller = Float_Expression()
			twistHelpers[4].scale.controller.Z_Scale.controller.AddScalarTarget "length" exposeDistance.distance.controller
			twistHelpers[4].scale.controller.Z_Scale.controller.AddScalarTarget "global" globalControl.scale.controller.Y_Scale.controller
			twistHelpers[4].scale.controller.Z_Scale.controller.AddScalarTarget "active" globalControl.modifiers[#Attribute_Holder].globalControlControls.active.controller
			twistHelpers[4].scale.controller.Z_Scale.controller.SetExpression "if(active=1,(pow((10 * global / length), 0.5)), 1)"
		)
		
		ProgressBarTool.SetProgress value:currStep count:numSteps message:"Finishg tpFlexiRig setup ..." 
		
		-- Create envelope objects (objects that will be skinned)
		envelopeObjects = #()
		for i = 1 to 5 do
		(
			envelopeObjects[i] = copy anchors[i]
			envelopeObjects[i].box = true
			envelopeObjects[i].centermarker = false
			envelopeObjects[i].size = 5
			envelopeObjects[i].name = prefix + "Bn_" + GetAlphabeticValue i + "01"
			envelopeObjects[i].parent = twistHelpers[i]
			FreezeTransform envelopeObjects[i]
			QuickAlign envelopeObjects[i] anchors[i]
			FreezeTransform envelopeObjects[i]
		)

		-- Working test
		/*b1 = box width: 2.5 height:2.5 length:2.5
		CenterPivot b1
		QuickAlign b1 twistHelpers[2]
		b1.parent = twistHelpers[2]

		b2 = box width: 2.5 height:2.5 length:2.5
		CenterPivot b2
		QuickAlign b2 twistHelpers[3]
		b2.parent = twistHelpers[3]

		b3 = box width: 2.5 height:2.5 length:2.5
		CenterPivot b3
		QuickAlign b3 twistHelpers[4]
		b3.parent = twistHelpers[4]*/

		-- Order layer system
		hiddenLayer = LayerManager.newLayer()
		layerName = prefix + "Hidden"
		hiddenLayer.setName layerName
		hiddenLayer.isHidden = true
		defaultLayer = LayerManager.getLayer 0
		defaultLayer.current = true

		for i = 1 to 5 do
			hiddenLayer.addNode anchors[i]

		for i = 1 to 5 do
			hiddenLayer.addNode twistHelpers[i]

		for i = 1 to 5 do
			hiddenLayer.addNode twistHelpersRotation[i]

		for i = 1 to 5 do
			hiddenLayer.addNode twistHelpersRotationGroups[i]

		hiddenLayer.addNode bendControlGroup
		hiddenLayer.addNode exposeDistance
		hiddenLayer.addNode spline

		-- Clean all the system
		globalGroupName = prefix + "Rig01"
		globalGroup = group globalControl name:globalGroupName
		attachNodesToGroup spline globalGroup
		setGroupOpen globalGroup true
		FreezeTransform globalGroup
		hiddenLayer.addNode globalGroup
		setTransformLockFlags globalGroup #{1..9}

		deselect $
		
		destroyDialog ProgressBarTool.instUI
		ProgressBarTool.instUI=undefined
		
		destroyDialog flexiRollout
		flexiRollout=undefined
		
		print "tpFlexiLineRig created succesfully!"
	)
	catch
	(
		try(destroyDialog ProgressBarTool.instUI;ProgressBarTool.instUI=undefined)catch()
		print("ERROR: tpFlexiLineRig could not be created")
	)
)

---------------------------------------------------------------------------------------------
-- INTERFAZ
---------------------------------------------------------------------------------------------
if((flexiRollout != undefined) and (flexiRollout.isDisplayed)) do
	(destroyDialog flexiRollout)
	
rollout flexiRollout "tpFlexiLineRig" width:175 height:145
(
	group "Properties"
	(
		checkbox chkTwist "Twist" height:23 checked: true
		checkbox chkStretch "Squash Stretch" checked:true height:23
	)
	
	button btnCreate "Create Flexi Line Setup" height:31
	hyperlink lbl4 "Tomás Poveda - www.cgart3d" address:"www.cgart3d.com" height:17 

	on btnCreate pressed  do with undo label:("Removing tpFlexiLine") on
	(
		createFlexiSystem()
	)
)
createDialog flexiRollout