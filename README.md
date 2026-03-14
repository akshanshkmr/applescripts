# Shortcuts

AppleScript automation for connecting to and disconnecting from a work PC over VPN.

## Requirements

- **Cisco Secure Client** — VPN client
- **Jump Desktop** — RDP client
- **Safari** — used for VPN web authentication
- macOS Accessibility permissions granted to Script Editor / osascript

## Scripts

### `login.scpt`

Connects to VPN and opens an RDP session.

**Flow:**
1. Opens Cisco Secure Client
2. If already connected (Disconnect button present) → skips to step 4
3. If not connected → clicks Connect, then waits up to 3 minutes for Safari web auth to complete
4. Opens Jump Desktop and connects to `goldenchinar` via the dock menu
5. Closes the Jump Desktop Computers window

**Run:**
```
osascript login.scpt
```

**Configuration** (top of file):
| Property | Default | Description |
|---|---|---|
| `PC_NAME` | `goldenchinar` | Name of the RDP connection in Jump Desktop |
| `MAX_WAIT` | `180` | Seconds to wait for VPN web auth |

---

### `logout.scpt`

Disconnects from VPN and closes all related apps.

**Flow:**
1. Force quits Jump Desktop
2. Opens Cisco Secure Client, clicks Disconnect if connected
3. Force quits Cisco Secure Client
4. Closes the "Logout successful" Safari tab if present

**Run:**
```
osascript logout.scpt
```

## Permissions

On first run, macOS will prompt for Accessibility access. Go to:

**System Settings → Privacy & Security → Accessibility**

and enable access for Terminal (or whichever app runs the scripts).
