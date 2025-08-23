local M = {}

function M:peek(job)
	local start, cache = os.clock(), ya.file_cache(job)
	if not cache then
		return
	end

	local ok, err, bound = self:preload(job)
	if bound and bound > 0 then
		return ya.emit("peek", { bound - 1, only_if = job.file.url, upper_bound = true })
	elseif not ok or err then
		return ya.preview_widget(job, err)
	end

	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

	local _, err = ya.image_show(cache, job.area)
	ya.preview_widget(job, err)
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = ya.clamp(-1, job.units, 1)
		ya.emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
	end
end

function M:preload(job)
	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	local output, err = Command("ddjvu")
		:arg({
			"-format=ppm",
			"-page=" .. (job.skip + 1),
			"-size=" .. rt.preview.max_width .. "x" .. "-1",
			"-aspect=yes",
			tostring(job.file.url),
			tostring(cache)
		})
		:stderr(Command.PIPED)
		:output()

	if not output then
		return true, Err("Failed to start `ddjvu`, error: %s", err)
	elseif not output.status.success then
		local pages = job.skip > 0 and tonumber(output.stderr:match("contains (%d+) pages"))
		return true, Err("Failed to convert DjVu to PPM, stderr: %s", output.stderr), pages
	end

	return true
end

return M
