-- Cisco Secure Client Logout Script

-- Constants
property RDP_APP : "Jump Desktop"
property VPN_APP : "Cisco Secure Client"
property LOGOUT_TITLE : "Logout successful"
property MAX_WAIT : 5

-- Helper Functions
on forceQuit(appName)
	try
		do shell script "pkill -f " & quoted form of appName
	end try
end forceQuit

on closeSafariTabContaining(targetText)
	tell application "Safari"
		repeat with w in windows
			repeat with t in tabs of w
				if name of t contains targetText then
					close t
					return true
				end if
			end repeat
		end repeat
	end tell
	return false
end closeSafariTabContaining

on waitForLogoutTab()
	set waited to 0
	set found to false

	repeat while (found is false) and (waited < MAX_WAIT)
		try
			set found to closeSafariTabContaining(LOGOUT_TITLE)
		end try

		if not found then
			delay 1
			set waited to waited + 1
		end if
	end repeat

	return found
end waitForLogoutTab

on disconnectVPN()
	tell application VPN_APP to activate
	tell application "System Events"
		tell process VPN_APP
			repeat until (count windows) > 0
				delay 0.2
			end repeat
			repeat with w in windows
				if (exists button "Connect" of w) or (exists button "Disconnect" of w) then
					if exists button "Disconnect" of w then
						click button "Disconnect" of w
						delay 1
					end if
						exit repeat
				end if
			end repeat
		end tell
	end tell
	do shell script "pkill -x " & quoted form of VPN_APP
end disconnectVPN

-- Main Logic
forceQuit(RDP_APP)
disconnectVPN()
waitForLogoutTab()
