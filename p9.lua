--[[
p9.lua: yet another 9patch library for Love2D.
https://github.com/codecat/p9
MIT Licensed; Copyright © 2024 Melissa Geels
]]

local shader = love.graphics.newShader([[
uniform vec4 middle;
uniform vec2 dest_size;

vec4 effect(vec4 color, Image tex, vec2 c, vec2 screen_coords)
{
	vec4 ret;
	float right = dest_size.x - (1 - middle.z);
	float bottom = dest_size.y - (1 - middle.w);

	// top
	if (c.y < middle.y) {
		// left
		if (c.x < middle.x) ret = Texel(tex, c);
		// top
		else if (c.x >= middle.x && c.x < right) {
			float x = mod(c.x - middle.x, middle.z - middle.x);
			ret = Texel(tex, vec2(middle.x + x, c.y));
		}
		// right
		else ret = Texel(tex, vec2(middle.z + c.x - right, c.y));
	}
	// middle
	else if (c.y >= middle.y && c.y < bottom) {
		// left
		if (c.x < middle.x) {
			float y = mod(c.y - middle.y, middle.w - middle.y);
			ret = Texel(tex, vec2(c.x, middle.y + y));
		}
		// middle
		else if (c.x >= middle.x && c.x < right) {
			float x = mod(c.x - middle.x, middle.z - middle.x);
			float y = mod(c.y - middle.y, middle.w - middle.y);
			ret = Texel(tex, vec2(middle.x + x, middle.y + y));
		}
		// right
		else {
			float y = mod(c.y - middle.y, middle.w - middle.y);
			ret = Texel(tex, vec2(middle.z + c.x - right, middle.y + y));
		}
	// bottom
	} else {
		// left
		if (c.x < middle.x) ret = Texel(tex, vec2(c.x, middle.w + c.y - bottom));
		// bottom
		else if (c.x >= middle.x && c.x < right) {
			float x = mod(c.x - middle.x, middle.z - middle.x);
			ret = Texel(tex, vec2(middle.x + x, middle.w + c.y - bottom));
		}
		// right
		else ret = Texel(tex, vec2(middle.z + c.x - right, middle.w + c.y - bottom));
	}

	return ret * color;
}
]])

function findImageLineRange(img, stride, offset, hor)
	local s, e = -1, -1

	for i = 1, stride - 2 do
		local r, g, b, a
		if hor then
			r, g, b, a = img:getPixel(i, offset)
		else
			r, g, b, a = img:getPixel(offset, i)
		end
		local rgb = r + g + b

		if s == -1 and a == 1 then
			if rgb ~= 0 then
				if hor then
					error('Unexpected pixel color at ' .. i .. ', ' .. offset)
				else
					error('Unexpected pixel color at ' .. offset .. ', ' .. i)
				end
			end
			s = i
		elseif s ~= -1 and e == -1 and a == 0 then
			e = i - s
			break
		end
	end

	if e == -1 then
		e = stride - s
	end

	return s, e
end

local M = {}

function M.load(path)
	local self = {}

	self.path = path
	self.imagedata = love.image.newImageData(path)
	self.image = love.graphics.newImage(self.imagedata)
	self.image:setWrap('repeat', 'repeat')
	local w, h = self.image:getDimensions()
	self.quad = love.graphics.newQuad(0, 0, w, h, w, h)

	local sx, sw = findImageLineRange(self.imagedata, w, 0, true)
	local sy, sh = findImageLineRange(self.imagedata, h, 0, false)
	local cx, cw = findImageLineRange(self.imagedata, w, h - 1, true)
	local cy, ch = findImageLineRange(self.imagedata, h, w - 1, false)

	self.middle = { sx / w, sy / h, (sx + sw) / w, (sy + sh) / h }
	self.content = { cx, cy, cw, ch }
	self.dx, self.dy, self.dw, self.dh = 0, 0, 0, 0

	function self:getContentWindow()
		local w, h = self.image:getWidth(), self.image:getHeight()
		local cx, cy, cw, ch = unpack(self.content)

		local rx = self.dx + cx - 1
		local ry = self.dy + cy - 1
		local rw = math.max(0, self.dw - cx - (w - cx - cw) + 2)
		local rh = math.max(0, self.dh - cy - (h - cy - ch) + 2)

		return rx, ry, rw, rh
	end

	function self:draw(x, y, w, h)
		local prevShader = love.graphics.getShader()

		if w < 0 then
			w = w * -1
			x = x - w
		end

		if h < 0 then
			h = h * -1
			y = y - h
		end

		love.graphics.push()
		love.graphics.translate(math.floor(x), math.floor(y))
		love.graphics.setShader(shader)

		shader:send('middle', self.middle)
		shader:send('dest_size', {
			(w + 2) / self.image:getWidth(),
			(h + 2) / self.image:getHeight(),
		})
		self.quad:setViewport(1, 1, w, h, self.image:getDimensions())
		love.graphics.draw(self.image, self.quad)

		love.graphics.setShader(prevShader)
		love.graphics.pop()

		self.dx, self.dy, self.dw, self.dh = x, y, w, h

		return self:getContentWindow()
	end

	return self
end

return M
