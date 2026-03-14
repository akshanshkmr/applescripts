-- Cisco Secure Client Login Script

-- Constants
property SUCCESS_TITLE : "Authentication successful"
property ERROR_TITLE : "Login error"
property SIGNIN_KEYWORD : "Sign In"
property VPN_APP : "Cisco Secure Client"
property RDP_APP : "Jump Desktop"
property PC_NAME : "goldenchinar"

-- Timeout for login (in seconds)
property MAX_WAIT : 180


-- Helper Functions
on findTargetWindow()
	tell application "System Events"
		tell process VPN_APP
			repeat until (count windows) > 0
				delay 0.1
			end repeat
			-- Find the window that has the Connect or Disconnect button
			repeat with w in windows
				if (exists button "Connect" of w) or (exists button "Disconnect" of w) then
					return w
				end if
			end repeat
		end tell
	end tell
	return missing value
end findTargetWindow


on closeSafariTabWithTitle(targetTitle)
	tell application "Safari"
		try
			repeat with w in windows
				repeat with t in tabs of w
					if name of t is targetTitle then
						close t
						return true
					end if
				end repeat
			end repeat
		end try
	end tell
	return false
end closeSafariTabWithTitle


on waitForSafariAuth()
	set waited to 0
	set authState to "pending"

	tell application "Safari"
		repeat while (authState is "pending") and (waited < MAX_WAIT)
			try
				set tabTitle to name of front document
				if tabTitle is SUCCESS_TITLE then
					set authState to "success"
				else if tabTitle is ERROR_TITLE then
					set authState to "error"
				else if tabTitle contains SIGNIN_KEYWORD then
					set authState to "pending"
				end if
			end try
			delay 2
			set waited to waited + 2
		end repeat
	end tell

	return authState
end waitForSafariAuth


on openRDPSession()
	tell application RDP_APP to activate

	-- Click goldenchinar directly from Jump Desktop dock menu
	tell application "System Events"
		tell process "Dock"
			repeat with d in UI elements of list 1
				try
					if name of d is RDP_APP then
						perform action "AXShowMenu" of d
						delay 0.5
						click menu item PC_NAME of menu 1 of d
						exit repeat
					end if
				end try
			end repeat
		end tell
	end tell
	-- Bring Computers window to front then close it
	delay 1
	tell application "System Events"
		tell process RDP_APP
			click menu item "Computers" of menu "Window" of menu bar 1
			delay 0.3
			click menu item "Close Window" of menu "File" of menu bar 1
		end tell
	end tell
end openRDPSession


-- Main Logic
tell application VPN_APP to activate

set authState to "pending"
set targetWindow to findTargetWindow()

if targetWindow is not missing value then
	delay 1
	tell application "System Events"
		tell process VPN_APP
			if exists button "Disconnect" of targetWindow then
				-- VPN already connected, go straight to RDP
				set authState to "alreadyConnected"
			else if exists button "Connect" of targetWindow then
				click button "Connect" of targetWindow
				set authState to "pending"
			end if
		end tell
	end tell
else
	display dialog "No Cisco Secure Client window found." buttons {"OK"} default button "OK"
end if


-- Handle results
if authState is "alreadyConnected" then
	openRDPSession()

else if authState is "pending" then
	set authState to waitForSafariAuth()

	if authState is "success" then
		closeSafariTabWithTitle(SUCCESS_TITLE)
		openRDPSession()

	else if authState is "error" then
		display dialog "Login error — check your credentials." buttons {"OK"} default button "OK"

	else
		display dialog "Authentication timed out after " & MAX_WAIT & " seconds." buttons {"OK"} default button "OK"
	end if
end if
