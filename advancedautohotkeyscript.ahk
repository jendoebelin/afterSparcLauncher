;==========================================
; Author ........: vrsportsfan
; Released ......: 2024-08-11
; Modified ......: 2024-08-11
; Tested with....: AutoHotkey v2.0.18 (x64)
; Tested on .....: Windows 11 - 22H2 (x64)
; Purpose  ......: Search to see if game is installed (redirects if not)
; 		   Looks up IPAddress of Arena and Launches Sparc Game into custom Arena

; Define the search directory and filename and game mode
searchDir := "C:\Sparc\VRArena\Binaries\Win64\"
fileName := "VRArena-Win64-Test.exe"
gameMode := "advanced"

; Search for the file
filePath := ""
Loop Files searchDir fileName
{
    filePath := A_LoopFileFullPath
    break
}

; Check if the file was found
if (filePath != "")
{
    ; Run the found file
    ; MsgBox "File found."
}
else
{
; Error message for missing file and redirection to archive link
MsgBox "File " fileName " not found. Install the archive into this directory " searchDir

; Opening web browser
Run "chrome.exe https://archive.org/details/Sparc --new-window "

exit
}

;==========================================
; Author ........: jNizM
; Released ......: 2021-04-30
; Modified ......: 2023-01-12
; Tested with....: AutoHotkey v2.0.2 (x64)
; Tested on .....: Windows 11 - 22H2 (x64)
; Function ......: ResolveHostname( HostName )
;
; Parameter(s)...: HostName - the hostname to be resolved
;
; Return ........: Gets the IP Address from a Hostname (Resolve Hostname to IP Address) like nslookup.
; ===========================================

#Requires AutoHotkey v2.0


ResolveHostname(HostName)
{
	static WSA_SUCCESS := 0
	static AF_INET     := 2
	static SOCK_STREAM := 1
	static IPPROTO_TCP := 6

	WSADATA := Buffer(394 + (A_PtrSize - 2) + A_PtrSize)
	if (DllCall("ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", WSADATA) != WSA_SUCCESS)
	{
		throw OSError(DllCall("ws2_32\WSAGetLastError"))
	}

	hints := Buffer(16 + 4 * A_PtrSize, 0)
	NumPut("Int", AF_INET,     hints,  4)
	NumPut("Int", SOCK_STREAM, hints,  8)
	NumPut("Int", IPPROTO_TCP, hints, 12)
	if (DllCall("ws2_32\GetAddrInfoW", "Str", HostName, "Ptr", 0, "Ptr", hints, "Ptr*", &result := 0) != WSA_SUCCESS)
	{
		DllCall("ws2_32\WSACleanup")
		throw OSError(DllCall("ws2_32\WSAGetLastError"))
	}

	addrinfo := result
	IPList := Array()
	while (addrinfo)
	{
		ai_addr    := NumGet(addrinfo, 16 + 2 * A_PtrSize, "Ptr")
		ai_addrlen := NumGet(addrinfo, 16, "UInt")
		DllCall("ws2_32\WSAAddressToStringW", "Ptr", ai_addr, "UInt", ai_addrlen, "Ptr", 0, "Ptr", 0, "UInt*", &AddressStringLength := 0)
		AddressString := Buffer(AddressStringLength << 1)
		if (DllCall("ws2_32\WSAAddressToStringW", "Ptr", ai_addr, "UInt", ai_addrlen, "Ptr", 0, "Ptr", AddressString, "UInt*", AddressString.Size) != WSA_SUCCESS)
		{
			DllCall("ws2_32\FreeAddrInfoW", "Ptr", result)
			DllCall("ws2_32\WSACleanup")
			throw OSError(DllCall("ws2_32\WSAGetLastError"))
		}
		IPList.Push(StrGet(AddressString))
		addrinfo := NumGet(addrinfo, 16 + 3 * A_PtrSize, "Ptr")
	}

	DllCall("ws2_32\FreeAddrInfoW", "Ptr", result)
	DllCall("ws2_32\WSACleanup")
	return IPList
}


IPList := ResolveHostname(gameMode ".aftersparc.com")

; -----------------------------------
; Author ........: SplaTTer from Discord
; Released ......: 2024-07-27
; Modified ......: 2024-08-11
; Tested with....: AutoHotkey v2.0.18 (x64)
; Tested on .....: Windows 11 - 22H2 (x64)
; Purpose  ......: Launches Sparc executable, hits tilde key, inputs "open" command


Run searchDir fileName
sleep(10000)

WinActivate "VRArena (64-bit, PCD3D_SM5)"
sleep(1500)
Send ("{vkC0sc029}") ; tilde key

sleep(200)
Send("open " IPList[1] ":7777{Enter}")
sleep(50)

