-- Downloads Folder Sorter
-- Sorts files into YYYY-MM folders based on date added
-- Files from current month are left in place
-- Within month folders: Images, Videos, and Music get subfolders

-- File type extensions
property imageExtensions : {"jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "webp", "heic", "heif", "svg", "ico", "raw", "cr2", "nef", "psd"}
property videoExtensions : {"mp4", "mov", "avi", "mkv", "wmv", "flv", "webm", "m4v", "mpeg", "mpg", "3gp", "ogv"}
property musicExtensions : {"mp3", "wav", "aac", "flac", "ogg", "wma", "m4a", "aiff", "aif", "opus"}

on run
	set downloadsFolder to POSIX path of (path to downloads folder)
	set currentDate to current date
	set currentYearMonth to getYearMonth(currentDate)

	-- Get list of files and folders in Downloads (excluding hidden and YYYY-MM folders we create)
	set itemList to paragraphs of (do shell script "find " & quoted form of downloadsFolder & " -maxdepth 1 \\( -type f -o -type d \\) -not -name '.*' -not -name '[0-9][0-9][0-9][0-9]-[0-9][0-9]' | grep -v '^" & downloadsFolder & "$'")

	repeat with itemPath in itemList
		try
			set itemPath to itemPath as text
			if itemPath is not "" then
				-- Get date added using mdls
				set dateAddedStr to do shell script "mdls -name kMDItemDateAdded -raw " & quoted form of itemPath

				if dateAddedStr is not "(null)" then
					-- Parse YYYY-MM from the date string (format: 2025-04-11 18:03:57 +0000)
					set itemYearMonth to text 1 thru 7 of dateAddedStr

					-- Skip items from the current month
					if itemYearMonth is not equal to currentYearMonth then
						-- Check if this is a directory
						set isDirectory to (do shell script "test -d " & quoted form of itemPath & " && echo 'yes' || echo 'no'") is "yes"

						-- Get item name and extension
						set itemName to do shell script "basename " & quoted form of itemPath
						set fileExt to getFileExtension(itemName)

						-- Create month folder if needed
						set monthFolderPath to downloadsFolder & itemYearMonth
						do shell script "mkdir -p " & quoted form of monthFolderPath

						-- Determine destination based on file type (folders stay in main month folder)
						set destinationFolder to monthFolderPath

						if not isDirectory then
							if fileExt is in imageExtensions then
								set destinationFolder to monthFolderPath & "/Images"
								do shell script "mkdir -p " & quoted form of destinationFolder
							else if fileExt is in videoExtensions then
								set destinationFolder to monthFolderPath & "/Videos"
								do shell script "mkdir -p " & quoted form of destinationFolder
							else if fileExt is in musicExtensions then
								set destinationFolder to monthFolderPath & "/Music"
								do shell script "mkdir -p " & quoted form of destinationFolder
							end if
						end if

						-- Move the item
						do shell script "mv " & quoted form of itemPath & " " & quoted form of destinationFolder & "/"
					end if
				end if
			end if
		on error errMsg
			-- Log error but continue with other items
			log "Error processing: " & itemPath & " - " & errMsg
		end try
	end repeat

	display notification "Downloads folder has been organized" with title "Download Sorter"
end run

-- Get YYYY-MM format from a date
on getYearMonth(theDate)
	set y to year of theDate as integer
	set m to month of theDate as integer
	if m < 10 then
		set mStr to "0" & (m as text)
	else
		set mStr to m as text
	end if
	return (y as text) & "-" & mStr
end getYearMonth

-- Get lowercase file extension
on getFileExtension(fileName)
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "."
	set parts to text items of fileName
	set AppleScript's text item delimiters to tid
	if (count of parts) > 1 then
		set ext to last item of parts
		-- Convert to lowercase
		set lowercaseExt to do shell script "echo " & quoted form of ext & " | tr '[:upper:]' '[:lower:]'"
		return lowercaseExt
	else
		return ""
	end if
end getFileExtension
