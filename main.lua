-- DjVu Preview Plugin for Yazi
-- This plugin allows previewing DjVu files by converting them to images

local M = {}

function M:peek(job)
	-- Get cache path and check if it exists
	local start, cache = os.clock(), ya.file_cache(job)
	if not cache then
		return
	end

	-- Preload the image (convert DjVu to JPEG)
	local ok, err = self:preload(job)
	if not ok or err then
		return ya.preview_widget(job, err)
	end

	-- Add delay for smooth preview experience
	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

	-- Display the converted image
	local _, err = ya.image_show(cache, job.area)
	ya.preview_widget(job, err)
end

function M:seek(job)
	-- Handle page navigation for multi-page DjVu files
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = ya.clamp(-1, job.units, 1)
		ya.emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
	end
end

function M:preload(job)
	-- Get cache path
	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	-- First convert to PPM format (like nnn does), then convert to JPEG
	local ppm_cache = cache .. ".ppm"
	
	-- Use ddjvu to generate PPM
	local output, err = Command("ddjvu")
		:arg({
			"-format=ppm",
			"-page=" .. (job.skip + 1),
			tostring(job.file.url),
			ppm_cache
		})
		:stderr(Command.PIPED)
		:output()

	if not output then
		return true, Err("Failed to start `ddjvu`, error: %s", err)
	elseif not output.status.success then
		-- Handle page count detection
		return true, Err("Failed to convert DjVu to PPM, stderr: %s", output.stderr)
	end

	-- Convert PPM to JPEG with desired quality and sizing
	local convert_output, convert_err = Command("convert")
		:arg({
			ppm_cache,
			"-resize", rt.preview.max_width .. "x" .. rt.preview.max_height .. ">",
			"-quality", rt.preview.image_quality,
			tostring(cache)
		})
		:stderr(Command.PIPED)
		:output()

	-- Clean up temporary PPM file
	pcall(os.remove, ppm_cache)

	if not convert_output then
		return true, Err("Failed to start `convert`, error: %s", convert_err)
	elseif not convert_output.status.success then
		return true, Err("Failed to convert PPM to JPEG, stderr: %s", convert_output.stderr)
	end

	return true
end

return M
