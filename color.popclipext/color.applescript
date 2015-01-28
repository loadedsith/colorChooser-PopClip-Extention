property hexChrs : "0123456789abcdef"
global debug
set debug to false

global outputPrefix
set outputPrefix to ""

global originalColor
set the originalColor to "{popclip text}"

global results

global originalApplication
tell application "System Events"
	set originalApplication to name of the first process whose frontmost is true
end tell


if (originalColor contains "popclip text") then
	set initialState to "00ff00" #for initial state
	set originalColor to initialState
	#for debugging
	#set test1 to "00ff00"
	#set test2 to "#00ff00"
	#set originalColor to test1
end if

if debug then
	display alert "got color selected:" & originalColor buttons {"OK"}
end if


try
	#delay 2
	#if debug then
	#display alert "try:" buttons {"OK"}
	#end if
	if (originalColor contains "#") then
		set the originalColor to trim_line(originalColor, "#", 0)
		set outputPrefix to outputPrefix & "#"
	end if
	set the originalColor to cssHexColor_To_RGBColor(originalColor)
	set the RGB16bit_list to (choose color default color originalColor)
on error
	#if debug then
	display alert "error:" buttons {"OK"}
	#end if
	set the RGB16bit_list to choose color
end try

set the results to RGB_to_HEX(RGB16bit_list)

if debug then
	#display alert "got color hex:" & result buttons {"OK"}
end if

tell application originalApplication
	activate
end tell
tell application "System Events"
	tell (1st process whose frontmost is true)
		keystroke results
	end tell
end tell

on RGB_to_HEX(RGB_values)
	-- this subroutine was taken from "http://www.apple.com/applescript/sbrt/sbrt-04.html"
	set the hex_list to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
	set the the hex_value to ""
	repeat with i from 1 to the count of the RGB_values
		set this_value to (item i of the RGB_values) div 256
		if this_value is 256 then set this_value to 255
		set x to item ((this_value div 16) + 1) of the hex_list
		set y to item (((this_value / 16 mod 1) * 16) + 1) of the hex_list
		set the hex_value to (the hex_value & x & y) as string
	end repeat
	return (outputPrefix & the hex_value)
end RGB_to_HEX

on cssHexColor_To_RGBColor(h) -- convert
	
	
	if (count h) < 6 then my badColor(h)
	
	set astid to text item delimiters
	set rgbColor to {}
	try
		repeat with i from 1 to 6 by 2
			
			set end of rgbColor to ((my getHexVal(text i of h)) * 16 + (my getHexVal(text (i + 1) of h))) * 257
		end repeat
	end try
	
	set text item delimiters to astid
	if (count rgbColor) < 3 then my badColor(h)
	
	return rgbColor
end cssHexColor_To_RGBColor

on getHexVal(c)
	if c is not in hexChrs then error
	set text item delimiters to c
	return (count text item 1 of hexChrs)
end getHexVal

on badColor(n)
	display alert n & " is not a valid css hex color" buttons {"OK"} cancel button "OK"
end badColor
on trim_line(this_text, trim_chars, trim_indicator)
	-- 0 = beginning, 1 = end, 2 = both
	set x to the length of the trim_chars
	-- TRIM BEGINNING
	if the trim_indicator is in {0, 2} then
		repeat while this_text begins with the trim_chars
			try
				set this_text to characters (x + 1) thru -1 of this_text as string
			on error
				-- the text contains nothing but the trim characters
				return ""
			end try
		end repeat
	end if
	-- TRIM ENDING
	if the trim_indicator is in {1, 2} then
		repeat while this_text ends with the trim_chars
			try
				set this_text to characters 1 thru -(x + 1) of this_text as string
			on error
				-- the text contains nothing but the trim characters
				return ""
			end try
		end repeat
	end if
	return this_text
end trim_line