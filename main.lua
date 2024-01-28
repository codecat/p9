local p9 = require('p9')

local patches = {
	p9.load('img/frame.9.png'),
	p9.load('img/hwrframe.9.png'),
	p9.load('img/notepad.9.png'),
}

local current_patch = 1

function love.wheelmoved(x, y)
	current_patch = math.max(1, math.min(#patches, current_patch + y))
end

function love.draw()
	local ox, oy = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
	local p = patches[current_patch]

	love.graphics.setColor(1, 1, 1)
	love.graphics.print('Move the mouse to resize the frame.\n' ..
		'Scroll the mouse up and down to change current patch.', 5, 5)

	-- Draw the patch from the window center to the mouse
	p:draw(ox, oy, love.mouse.getX() - ox, love.mouse.getY() - oy)

	-- Draw content within the patch's content area
	local x, y, w, h = p:getContentWindow()
	love.graphics.setScissor(x, y, w, h)
	love.graphics.setColor(1, 0, 0)
	love.graphics.printf(
		'Lorem ipsum dolor sit amet, exercitationem placeat natus repudiandae nobis vitae beatae' ..
		' quos eaque tenetur et rerum totam asperiores itaque impedit quam et suscipit id earum' ..
		' rerum doloribus perferendis accusantium ab natus est vel est nobis quaerat consequatur' ..
		' possimus et ea excepturi esse sint officiis reprehenderit optio voluptatem neque quam' ..
		' ea et soluta nostrum totam culpa ut velit quia omnis et voluptatem aut numquam id veniam' ..
		' corrupti ut sit officia ipsum non sed ut rerum enim placeat ullam neque animi enim' ..
		' consectetur rerum est est ut perferendis consectetur quos voluptatibus velit facere ipsa' ..
		' saepe veritatis molestias optio in velit illum minima ad ducimus quam deleniti quaerat' ..
		' voluptas voluptatum voluptatem quasi nulla omnis ut nam earum omnis et delectus quos' ..
		' veritatis dolor nihil rerum minus dolores architecto odio vitae veniam dicta ipsam est sed' ..
		' officia dolorem natus tempore consequuntur ut maxime odio et magni fugit a aperiam libero' ..
		' blanditiis sint nihil earum ipsa error dignissimos rerum.', x, y, w)
	love.graphics.setScissor()
end
