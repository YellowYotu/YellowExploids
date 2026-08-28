-- A90 FREEZE --

local ACTION_NAME = "Yell00A90Freeze"
local CAMERA_FREEZE_NAME = "Yell00A90CameraFreeze"

local frozenCameraCFrame = nil
local previousMouseBehavior = nil

local function sinkMovement()
	return Enum.ContextActionResult.Sink
end

local function enableA90Freeze()
	ContextActionService:BindActionAtPriority(
		ACTION_NAME,
		sinkMovement,
		false,
		999999,
		Enum.PlayerActions.CharacterForward,
		Enum.PlayerActions.CharacterBackward,
		Enum.PlayerActions.CharacterLeft,
		Enum.PlayerActions.CharacterRight,
		Enum.PlayerActions.CharacterJump,
		Enum.UserInputType.MouseMovement
	)

	local camera = workspace.CurrentCamera

	if camera then
		frozenCameraCFrame = camera.CFrame
	end

	previousMouseBehavior = UserInputService.MouseBehavior

	pcall(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end)

	RunService:BindToRenderStep(
		CAMERA_FREEZE_NAME,
		Enum.RenderPriority.Camera.Value + 1,
		function()
			if not isA90Active() or not a90FreezeEnabled then
				return
			end

			if root then
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end

			local currentCamera = workspace.CurrentCamera

			if currentCamera and frozenCameraCFrame then
				currentCamera.CFrame = frozenCameraCFrame
			end
		end
	)
end

local function disableA90Freeze()
	ContextActionService:UnbindAction(ACTION_NAME)

	pcall(function()
		RunService:UnbindFromRenderStep(CAMERA_FREEZE_NAME)
	end)

	if previousMouseBehavior then
		pcall(function()
			UserInputService.MouseBehavior = previousMouseBehavior
		end)
	end

	frozenCameraCFrame = nil
	previousMouseBehavior = nil
end

addConnection(a90Remote.OnClientEvent:Connect(function()
	a90ActiveUntil = os.clock() + A90_FREEZE_TIME

	playWarningSound()
	showWarning("A90 DETECTED\nDO NOT MOVE OR LOOK • 2 SECOND FREEZE")

	if a90FreezeEnabled then
		disableA90Freeze()
		enableA90Freeze()

		if root then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end

	task.delay(A90_FREEZE_TIME, function()
		if not running then
			return
		end

		if not isA90Active() then
			disableA90Freeze()
		end
	end)
end))
