#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         ayaducy

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------
#include <File.au3>
#include <FileConstants.au3>
#include <Array.au3>
#include <Crypt.au3>
#include <Date.au3>

; Ask the user whether to delete or move the duplicate file
Local $sFlag = InputBox("Duplicate File Remover", "Enter 'D' to delete duplicate files or 'M' to move duplicate files to backup folder")

; If the user cancels the selection, exit the script
If @error Then
    Exit
EndIf

; If user input is incorrect
If StringUpper($sFlag) <> "D" And StringUpper($sFlag) <> "M" Then
	MsgBox(16, "Error", "Please enter D or M")
	Exit
EndIf

; Select the directory path using the FileSelectFolder function
Local $sDirPath = FileSelectFolder("Select the directory path where the files are located", "", 0)

; If the user cancels the selection, exit the script
If @error Then
    Exit
EndIf

; Create or clear the log file in the directory
Local $hFile = FileOpen($sDirPath & "\_log.txt", $FO_OVERWRITE)

; If the log file could not be created or cleared, exit the script
If $hFile = -1 Then
    MsgBox(16, "Error", "Could not create or clear log file")
    Exit
EndIf

; Start time
FileWriteLine($hFile,"Check duplicate files by ayaducy")
FileWriteLine($hFile,"Start at:" & _NowCalc())

; Close the log file handle
FileClose($hFile)

; Get all the files in the directory
Local $aFiles = _FileListToArray($sDirPath, "*", $FLTA_FILES)

; Create an empty array to store the MD5 hashes of the files
Local $aHashes[1]

; Initialize the counter for deleted files
Local $iDeletedFiles = 0


If StringUpper($sFlag) = "M" Then
	; Create the backup folder if it does not exist
	If Not FileExists($sDirPath & "\_backup") Then
		DirCreate($sDirPath & "\_backup")
	EndIf

	For $i = 0 To UBound($aFiles) - 1

		; Generate the MD5 hash of the file
		Local $sHash = _Crypt_HashFile($sDirPath & "\" & $aFiles[$i], $CALG_MD5)

		; Check if the hash already exists in the array
		If _ArraySearch($aHashes, $sHash) >= 0 Then

			; Move the duplicate file
			FileMove($sDirPath & "\" & $aFiles[$i], $sDirPath & "\_backup\" & $aFiles[$i], $FC_CREATEPATH)

			; Increment the counter for moved files
			$iDeletedFiles += 1

			; Append the name of the moved file to the log file
			$hFile = FileOpen($sDirPath & "\_log.txt", $FO_APPEND)
			FileWriteLine($hFile,_NowCalc() & " Moved file: " & $aFiles[$i])
			FileClose($hFile)

		Else

			; Add the hash to the array if it does not already exist
			_ArrayAdd($aHashes, $sHash)

		EndIf

	Next
Else

	For $i = 0 To UBound($aFiles) - 1

		; Generate the MD5 hash of the file
		Local $sHash = _Crypt_HashFile($sDirPath & "\" & $aFiles[$i], $CALG_MD5)

		; Check if the hash already exists in the array
		If _ArraySearch($aHashes, $sHash) >= 0 Then

			; Delete the duplicate file
			FileDelete($sDirPath & "\" & $aFiles[$i])

			; Increment the counter for deleted files
			$iDeletedFiles += 1

			; Append the name of the deleted file to the log file
			$hFile = FileOpen($sDirPath & "\_log.txt", $FO_APPEND)
			FileWriteLine($hFile,_NowCalc() & " Deleted file: " & $aFiles[$i])
			FileClose($hFile)

		Else

			; Add the hash to the array if it does not already exist
			_ArrayAdd($aHashes, $sHash)

		EndIf
	Next
EndIf

; Loop through each file in the directory


; Remove the first element of the array (it is empty)
_ArrayDelete($aHashes, 0)

; End time
Local $hFile = FileOpen($sDirPath & "\_log.txt", $FO_APPEND)
FileWriteLine($hFile,"End at:" & _NowCalc())
FileClose($hFile)

; Display the number of deleted files
If StringUpper($sFlag) = "D" Then
	MsgBox(0, "Files Deleted", "Number of deleted files: " & $iDeletedFiles)
ElseIf StringUpper($sFlag) = "M" Then
	MsgBox(0, "Files Moved", "Number of moved files: " & $iDeletedFiles)
EndIf

